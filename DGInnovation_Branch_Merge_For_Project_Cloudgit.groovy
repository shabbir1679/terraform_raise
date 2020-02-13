import groovy.json.JsonSlurper
import hudson.model.Run
import org.jenkinsci.plugins.workflow.support.steps.build.RunWrapper
import org.jenkinsci.plugins.scriptsecurity.sandbox.RejectedAccessException
//import org.jenkins.plugins.lockableresources
build_results = []
repositories = []
buildfails = []
reposfailed = [:]
def fail(msg)
{
  try
  {
    println msg
    currentBuild.result = "FAILURE"
  }
  catch(RejectedAccessException e) 
  {
	    throw e
  }
  catch(err) 
  {
    currentBuild.result = "FAILURE"
    println "caught error: "+err
  }
}
def getRepositories (url, jenkinsauth) 
{
  try
  {
    def uc = (HttpURLConnection) new URL(url).openConnection();
    uc.setConnectTimeout(2000);
    uc.setRequestProperty("Content-Type", "application/json");
    uc.setRequestProperty("Accept", "application/json");
    uc.setRequestProperty ('Authorization',  "Basic $jenkinsauth");
    uc.setDoOutput(true);
    uc.connect();
    uc.setReadTimeout(2000);

    if (uc.responseCode == 200) 
    {
      return new groovy.json.JsonSlurper().parseText(uc.content.text).values['slug']
    }
    else
    {
      println "Validate url ${url} response code: ${uc.responseCode}"
      currentBuild.result = "FAILURE"
      return false;
    }
  }
  catch(RejectedAccessException e) 
  {
	    throw e
  }
  catch(err) 
  {
    currentBuild.result = "FAILURE"
    println "caught error: "+err
  }
}
def dobuild (repos,repo,proj,fromBranch,toBranch,jiraIssue,dryRun,forceMerge,bitbucket)
{
  try
  {
    return {
      node('newgitworker')
      {
        def jobname = forceMerge ? "Branch_Merge" : "Create_Branch_Pull"
        def jobget = build job: jobname, parameters: [string(name: 'Project', value: proj), string(name: 'Repository', value: repo), string(name: 'FromBranch', value: fromBranch), string(name: 'ToBranch', value: toBranch), booleanParam(name: 'DRYRUN', value: dryRun), string(name: 'JiraIssue', value: jiraIssue), string(name: 'bitbucket', value: bitbucket)], propagate: false
        build_results.add(jobget)   
        repositories.add(repo)
        def jobResult = jobget.getResult()
        buildfails.add(jobResult)
        if(jobResult == "FAILURE")
        {
          println "Failure in Repository - $repo with Build Number: ${jobget.getNumber()}"
          currentBuild.result = "FAILURE"
                    reposfailed.put(repo,jobget.getNumber())
        }
      }
    }
  }
  catch(RejectedAccessException e) 
  {
	    throw e
  }
  catch(err) 
  {
    currentBuild.result = "FAILURE"
    println "caught error: "+err
  }
}
def prepareBuilds = {params ->
  try
  {
    def calljobs = [:]
    def fromBranch = params['FromBranch'] // source branch
    def toBranch = params['ToBranch']     // target branch
    def projects = params['Projects']
    def forceMerge = params['ForceMerge'] ?: 'False'
    forceMerge = forceMerge.toLowerCase() in ['yes','true']
    def dryRun = params['DRYRUN'] ?: 'False'
    def bitbucket = params['bitbucket']
    def jiraIssue = params['JiraIssue'] ?: ''
    dryRun = dryRun.toLowerCase() in ['yes','true']
    if(!fromBranch && !toBranch && !projects)
    {
      fail("None of the inputs are given, please look into the parameters of the build")
      return false
    }
    if(!bitbucket)
    {
      fail("bitbucket URL must me Selected")
      return false
    }
    if(!projects)
    {
      fail("Project must be provided")
      return false
    }
    if(!fromBranch && !toBranch)
    {
      fail("From Branch and To Branch must be provided")
      return false
    }
    if(!fromBranch)
    {
      fail("From Branch must be provided")
      return false
    }
    if(!toBranch)
    {
      fail("To Branch must be provided")
      return false
    }
    if(!forceMerge)
    {
      fail("forceMerge = 'yes' must be provided")
      return false
    }
    withCredentials([string(credentialsId: 'ea903f76-c44e-44c3-874a-2106565a3bb7', variable: 'JENKINSAUTH')]) 
    {
      def a = Projects.split(',');
      for (int j=0; j < a.size(); j++) 
      {
        def proj = a [j]
        def bitbuckerUrl = "https://$bitbucket/rest/api/1.0/projects/${a[j]}/repos?limit=1000"
        def repos = getRepositories(bitbuckerUrl, JENKINSAUTH)
        if (repos)
        {
          for (repo in repos) 
          {
            calljobs["Repository: ${repo}"] = dobuild (repos,repo,proj,fromBranch,toBranch,jiraIssue,dryRun,forceMerge,bitbucket)
          }
        }
      }
    }
    return calljobs
  }
  catch(RejectedAccessException e) 
  {
	    throw e
  }
  catch(err) 
  {
    currentBuild.result = "FAILURE"
    println "caught error: "+err
  }
}
node ('newgitworker') 
{
  stage('Running')
  {
    try 
    {
      cleanWs()
      deleteDir()
      def b = prepareBuilds(params)
      if (b) 
      {
        parallel (b)
        print "--------------------------------------Printing Output of the called jobs--------------------------------------"
        for (i=0;i<build_results.size();i++)
        {
          println "\n==================== Starting output of Repository: ${repositories[i]} with Build Number: ${build_results[i].displayName}====================\n"
          print build_results[i].rawBuild.log
          println "\n==================== Ending output of Repository: ${repositories[i]} with Build Number: ${build_results[i].displayName}====================\n"
        }
        buildsuccessresult = buildfails.unique()
        if(buildsuccessresult.contains("SUCCESS") && buildsuccessresult.size() == 1)
        {
          println "All the build jobs seems to be Successfull"
        }
        if(buildfails.contains("FAILURE"))
        {
          currentBuild.result = "FAILURE"
        }
      }
            if (reposfailed)
            {
                    def constructstring = ""
                    def jobbuildurl = "https://jenkins.tsys.aws/common/job/Branch_Merge//"
                    reposfailed.each {rep, number ->
                        println "${rep} -> " + jobbuildurl + "$number"
                    }
                    reposfailed.each {rep, number ->
                        constructstring = constructstring + "${rep} -> " + jobbuildurl + "$number" + "\n"
                    }
                    mail body: "Branch merges failed for the following repos, more details: \n" + constructstring,
                            from: "branchmergejobs@tsys.com",
                            replyTo: "branchmergejobs@tsys.com",
                            subject: "branch merge has failed",
                            to: "${user}@tsys.com"
            }
      deleteDir() 
      cleanWs()
    }
    catch(RejectedAccessException e) 
    {
	    throw e
    }
    catch(err) 
    {
      currentBuild.result = "FAILURE"
      println "caught error : "+err
    }
  }
}
