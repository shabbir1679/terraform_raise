import datetime
import time
import logging
import requests as reqs
import json
import urllib3
import pprint
import os
import csv
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
log = logging.getLogger(__name__)
 
git_url = 'https://testgit.tsys.aws'
execption_branch_list = ['master', 'uat', 'Development', 'dev', 'integration', 'development', 'main']
dropdown = 750

def repo_all_list(git_url, project_key, start=None, limit=300):
    """
    Get all repositories list from project
    :param project_key:
    :return:
    """
    url = '{git_url}/rest/api/1.0/projects/{projectKey}/repos'.format(git_url=git_url,projectKey=project_key)
    headers = {'Content-Type': 'application/json'}
    params = {}
    if limit:
        params['limit'] = limit
    if start:
        params['start'] = start
    r = reqs.get(url, auth=('jenkinsreadonly', 'jenkinsreadonly'), headers=headers, params=params, verify=False)
    repos_dump = r.json()
    repo_list = []
    for value in repos_dump['values']:
        repo_list.append(value['slug'])
    # print(repo_list)
    return repo_list
    
# repo_all_list(git_url, 'ECP')
 
def get_all_branches(git_url, project_key, repo, base=None, filter=None, start=0, limit=99999, details=True, order_by='MODIFICATION'):
    
    url = '{git_url}/rest/api/1.0/projects/{project}/repos/{repository}/branches'.format(git_url=git_url,project=project_key,repository=repo)
    headers = {'Content-Type': 'application/json'}
    params = {}
    if start:
        params['start'] = start
    if limit:
        params['limit'] = limit
    if filter:
        params['filterText'] = filter
    if base:
        params['base'] = base
    if order_by:
        params['orderBy'] = order_by
    params['details'] = details
    # return (reqs.get(url, params=params) or {}).get('values')
    r = reqs.get(url, auth=('jenkinsreadonly', 'jenkinsreadonly'), headers=headers, params=params, verify=False)
    branches_dump = r.json()
    ## BRANCH_NAME
    if branches_dump and branches_dump.get('values'):
        all_values = branches_dump['values']
    else:
        if branches_dump and branches_dump.get('errors'):
            print (branches_dump.get('errors'))
        print ("skipping ", project_key+":"+repo)
        return
    repo_branch_list = []
    # final_string = []
    for brnc in all_values:
        branch = brnc['displayId']
        
        if branch in execption_branch_list:
            continue
        
        defaultbranch = brnc ['isDefault']
        ## TIMESTAMP
        if brnc['metadata']['com.atlassian.bitbucket.server.bitbucket-branch:latest-commit-metadata']:
            committer_timestamp = brnc['metadata']['com.atlassian.bitbucket.server.bitbucket-branch:latest-commit-metadata']['committerTimestamp']
        else:
            print("no value for latest-commit-metadata in project:repo:branch - ",brnc)
            continue
        insertion_date = datetime.datetime.fromtimestamp(committer_timestamp/1000.0)
        current_time = datetime.datetime.now()
        time_between_commiter = (current_time - insertion_date)
        ## COMMITTER
        committer_name = brnc['metadata']['com.atlassian.bitbucket.server.bitbucket-branch:latest-commit-metadata']['committer']['name']
        committer_email = brnc['metadata']['com.atlassian.bitbucket.server.bitbucket-branch:latest-commit-metadata']['committer']['emailAddress']
        if time_between_commiter.days<dropdown:
            if defaultbranch == False:
                repo_branch_list.append([project_key, repo, branch, str(time_between_commiter), committer_name, committer_email])
 
    return repo_branch_list
 
 
 
# get_all_branches('TOK')
 
def final_list(git_url, project_key):
    filename = project_key+".csv"
    outF = open(filename,"w")
    thewriter = csv.writer(outF)
    thewriter.writerow(["Proj-name", "repo-name", "branch-name", "last-commit-made", "Name", "E-mail"])
    repos = repo_all_list(git_url, project_key)
    for repo in repos:
        branches = []
        branches = get_all_branches(git_url, project_key, repo)
        print(branches)
        if branches:
            for branch in branches:
                thewriter.writerow(branch)
            # thewriter.writerow("\n")
            # print (branches)
    outF.close()
 
 
final_list(git_url, 'DTR')
 
 
 
 