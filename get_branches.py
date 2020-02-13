import json
import requests as reqs
import os
import sys
import json

#  ========
#  = URLs =
#  ========
hostname = 'https://tppqv1b732.qa.tpp.tsysecom.com'
#URLS = 'https://tppqv1b732.qa.tpp.tsysecom.com/rest/api/1.0/projects/ECP/repos/accountissuingapi/branches?limit=99999&details=True'
#URL = 'https://tppqv1b732.qa.tpp.tsysecom.com/rest/api/1.0/projects/ECP/repos/'
#headers = {'Content-Type': 'application/json'}
    # Get repos
#rr = reqs.get(URL, auth=('jenkinsreadonly', 'jenkinsreadonly'), headers=headers, verify=False)
    # Get tags & branches
#r = reqs.get(URLS, auth=('jenkinsreadonly', 'jenkinsreadonly'), headers=headers, verify=False)
#repos_dump = rr.json()
#branches_dump = r.json()
#print(repos_dump)
#print(branches_dump)
# for value in json_dump['values']:
#     print(value['displayId']) 
#     print (value['latestCommit'])

def get_repos(project_key):
    """
    Get a specific repository from a project. This operates based on slug not name which may
    be confusing to some users.
    :param project_key: Key of the project you wish to look in.
    :param repository_slug: url-compatible repository identifier
    :return: Dictionary of request response
    """

    url = '{hostname}/rest/api/1.0/projects/{project}/repos'.format(hostname=hostname,project=project_key)
    r = reqs.get(url, verify=False)
    print(r)


get_repos('ECP')
    





