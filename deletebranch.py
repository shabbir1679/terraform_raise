import datetime
import time
import logging
import requests as reqs
import json
import urllib3
import pprint
import csv
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
log = logging.getLogger(__name__)

hostname = 'https://testgit.tsys.aws'


def commit_time(mills):

    insertion_date = datetime.datetime.fromtimestamp(mills/1000.0)
    current_time = datetime.datetime.now()
    time_between_commiter = (current_time - insertion_date)
    # print(time_between_commiter)
    # print("this was committed:" + str(time_between_commiter))
    return time_between_commiter


    # if time_between_commiter.days>365:
    #     print("This commit was made 365 days ago it will be marked as to be deleted")
    # else:
    #     print("this commit is less than 365 days old are you sure want to delete it")
def project_all_list():
    pass

##### GET ALL REPOS AND STORE IT IN A LIST


def repo_all_list(hostname, project_key, start=None, limit=300):
    """
    Get all repositories list from project
    :param project_key:
    :return:
    """
    # all_projects = []
    # all_projects = project_all_list()

    # for project in project_list:

    url = '{hostname}/rest/api/1.0/projects/{project}/repos'.format(hostname=hostname,project=project_key)
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
    
# repo_all_list('ECP')


#### Get all branches and store it in a list

def get_all_branches(hostname, project_key, repo, base=None, filter=None, start=0, limit=99999, details=False, order_by='MODIFICATION'):
    branch_name_list = []
    branch_commit_time_list = []
    url = '{hostname}/rest/api/1.0/projects/{project}/repos/{repository}/branches'.format(hostname=hostname,project=project_key,repository=repo)
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
    r = reqs.get(url, auth=('jenkinsreadonly', 'jenkinsreadonly'), headers=headers, params=params, verify=False)
    branches_dump = r.json()
    all_values = branches_dump['values']
    for index in range(len(all_values)):
        branch_name_list.append(branches_dump['values'][index]['displayId'])
        # branch_commit_time_list(branches_dump['values'][index]['latestCommit'])
    return branch_name_list


#             ### DELETE A BRANCH

#### Print only those commits that are greater than 180 days

def get_commits_recursive(hostname, project_key, isLastPage=False, limit=25):
    repo_list = []
    repo_list = repo_all_list(hostname,project_key)
    for repo in repo_list:
        all_commits = []
        detailslist  = []
        branch_name_list = []
        branch_name_list = get_all_branches(hostname,project_key,repo)
        for branch in branch_name_list:
            url = '{hostname}/rest/api/1.0/projects/{project}/repos/{repository}/commits?until={branch_name}'.format(hostname=hostname,project=project_key,repository=repo,branch_name=branch)
            headers = {'Content-Type': 'application/json'}
            params = {}
            if limit:
                params['limit'] = limit
            if isLastPage:
                params['isLastPage'] = isLastPage
            rr = reqs.get(url, auth=('jenkinsreadonly', 'jenkinsreadonly'), headers=headers, params=params, verify=False)
            commits_dump = rr.json()
            all_commits = commits_dump['values']
            for index in all_commits:
                # # os.environ['days'] = '180'
                # input = os.getenv("no_day")
                # dropdown = int(input)
                committer_timestamp = index['committerTimestamp']
                # committer_timestamp = commit_time(committer_timestamp)
                committer_name = index['committer']['name']
                committer_email = index['committer']['emailAddress']
                insertion_date = datetime.datetime.fromtimestamp(index['committerTimestamp']/1000.0)
                current_time = datetime.datetime.now()
                time_between_commiter = (current_time - insertion_date)
                # print(time_between_commiter)
                # print("this was committed:" + str(time_between_commiter))
    return 
                    



# get_commits_recursive(hostname, 'TOK')
# commit_time(1574673840000)

def del_branch(hostname, project_key, repo, branch):
    url = '{hostname}/rest/branch-utils/1.0/projects/{project}/repos/{repository}/branches'.format(hostname=hostname,project=project_key,repository=repo)
    headers = {'Content-Type': 'application/json'}
    print(url)
    data = {"name": branch, "dryRun": 'false'}
    # data = json.dumps(data)
    # loaded_d = json.loads(data)
    print(data)
    d = reqs.delete(url, auth=('smohammed', 'Mommyd@d786'), headers=headers, data=json.dumps(data), verify=False)
    d.raise_for_status()


