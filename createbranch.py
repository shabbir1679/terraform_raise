import requests as reqs
import json
import urllib3
import pprint
import os
import csv
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

hostname = 'https://testgit.tsys.aws'


def create_branch(hostname, project_key, repo):
    url = '{hostname}/rest/api/1.0/projects/{project}/repos/{repository}/branches'.format(hostname=hostname,project=project_key,repository=repo)
    headers = {'Content-Type': 'application/json'}
    print(url)
    branch_list = ['test1', 'test2', 'test3', 'test4', 'test5', 'test6', 'test7', 'test8', 'test9', 'test10']
    for branch in branch_list:
        data = {"name": branch, "startPoint": 'refs/heads/master'}
        # data = json.dumps(data)
        # loaded_d = json.loads(data)
        print(data)
        d = reqs.post(url, auth=('smohammed', 'Mommyd@d786'), headers=headers, data=json.dumps(data), verify=False)
        print(d)

create_branch(hostname, 'ECP', 'accountissuingapi')



def create_sonar_branches():
    branch_list = ['test1', 'test2', 'test3', 'test4', 'test5', 'test6', 'test7', 'test8', 'test9', 'test10']
    for branch in branch_list:
        project_key = 'com.tsys' + ':' + 'accountissuingapi' + ':' + branch
        url = 'https://sonar-test.tools.tsys.aws/api/projects/create?name={branch}&project={project_key}'.format(project_key=project_key,branch=branch)
        r = reqs.post(url, auth=('admin', 'admin'), verify=False)
        print(r)

create_sonar_branches()

