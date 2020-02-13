import datetime
import time
import logging
import requests as reqs
import json
import urllib3
import pprint
import os
import csv
import oneproject as singleprojectbranchlist
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
log = logging.getLogger(__name__)

project_key = os.getenv("project_name")
# git_url = 'https://tppqv1b732.qa.tpp.tsysecom.com'
input = os.getenv("num_day")
dropdown = 10

# git_url = os.getenv("bitbucket_url")
git_url = 'https://testgit.tsys.aws'

def project_all_list(git_url, limit=99999):
    
    url = '{git_url}/rest/api/1.0/projects'.format(git_url=git_url)
    headers = {'Content-Type': 'application/json'}
    params = {}
    if limit:
        params['limit'] = limit
    r = reqs.get(url, auth=('smohammed', 'Mommyd@d786'), headers=headers, params=params, verify=False)
    project_dump = r.json()
    project_list = []
    for value in project_dump['values']:
        project_list.append(value['key'])
    return project_list

# project_all_list(git_url)


def allproject_branch_list():
    p = []
    p = project_all_list(git_url)
    # print(p)
    for project_key in p:
        print ("**********")
        print(project_key)
        print ("**********")
        singleprojectbranchlist.final_list(git_url, project_key)

if project_key:
    singleprojectbranchlist.final_list(git_url, project_key)
else:
    allproject_branch_list()