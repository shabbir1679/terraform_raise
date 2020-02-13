#!/bin/bash
chmod 755 /var/lib/jenkins/.ssh/id_rsa
cat ${jenkinsprivatekey} > /var/lib/jenkins/.ssh/id_rsa
chmod 500 /var/lib/jenkins/.ssh/id_rsa
elementIn () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}
if [[ "$FromBranch" == *"integration"* ]]; then
  EXCLUDE=("on_deck" "master" "HEAD")
else
  EXCLUDE=("master" "HEAD")
fi

if [[ ( "$ToBranch" == "master" ) || ( "$ToBranch" == "integration" ) || ( "$ToBranch" == "beta" ) ]]; then
  echo "To branch must not be be master, integration, or beta"
  exit 1
fi

#elif [[ "$FromBranch" == "master" ]]; then 
#  EXCLUDE=("master" "HEAD")
#else
#  echo "Source branch must be master, on_deck, or contain 'integration', not ${FromBranch}!"
#  exit 1
#fi

echo $Repository
echo $Project

if [ "$bitbucket" == git.tpp.tsysecom.com ]  || [ "$bitbucket" == test.git.tpp.tsysecom.com ]
then
    echo "git clone ssh://$bitbucket:1337/${Project}/${Repository}.git"
    GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone ssh://$bitbucket:1337/${Project}/${Repository}.git .
    git remote set-url origin ssh://git@$bitbucket:1337/$Project/$Repository.git
    GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git fetch --all
else 
    echo "git clone ssh://$bitbucket/${Project}/${Repository}.git"
    GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone ssh://$bitbucket/${Project}/${Repository}.git .
    git remote set-url origin ssh://git@$bitbucket/$Project/$Repository.git
    GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git fetch --all
fi

echo "Checking out $FromBranch"
git checkout -f $FromBranch
fromref=($(git show-ref --hash $FromBranch))
echo "fromref=$fromref"


mkdir -pv ".git/info"
echo "* -crlf" >> ".git/info/attributes"

echo ""
echo "Merging $Project/$Repository from $FromBranch to $ToBranch"
echo ""

RESULT=0
for BRANCH in $ToBranch
do
  echo ""
  echo "---------- Processing $Project/$Repository/$BRANCH"
  if ! elementIn "$BRANCH" "${EXCLUDE[@]}"; then
    echo "Checking out $BRANCH"
    git checkout -f $BRANCH
    if [ $? != 0 ]; then
      echo "Unable to check out branch $BRANCH."
      echo "Probably branch does not exist in this repo."
      echo "Continuing with next ToBranch!"
      continue
    fi
    echo "git reset --hard"
    git reset --hard
    if [ $? != 0 ]; then
      echo "Unexpected git error!"
      echo "Please contact digitaldevops."
      echo "Continuing with next ToBranch!"
      RESULT=2
      continue
    fi
    echo "git clean -xf"
  git config user.email "jenkins@tsys.com"
  git config user.name "Auto Deploy"
    git clean -xf
    if [ $? != 0 ]; then
      echo "Unexpected git error!"
      echo "Please contact digitaldevops."
      echo "Continuing with next ToBranch!"
      RESULT=2
      continue
    fi
    echo "git commit -a -m 'CDT-200 Fix line endings'"
    git commit -a -m "CDT-200 Fix line endings"

    echo "fromref=$fromref"
    toref=($(git show-ref --hash $BRANCH))
    echo "toref=$toref"
    mergebase=$(git merge-base $fromref $toref)
    echo "mergebase=$mergebase"
    diffstats=$(git diff --ignore-space-at-eol --shortstat $mergebase $fromref)
    echo "diffstats=$diffstats"
    if [ "$diffstats" == "" ]; then
      echo "$Project/$Repository/$FromBranch contains no significant updates to $BRANCH - skipping merge"
      continue
    fi

    echo "git merge origin/$FromBranch"
    git merge origin/$FromBranch
    if [ $? == 0 ]; then
      if [ "$DRYRUN" != "true" ]; then
        echo "git push origin"
        git push origin
        if [ $? != 0 ]; then
          RESULT=3
          echo "********** Push failed, creating pull request!"
          stash-cli https://$bitbucket -a createPullRequest --project "$Project" --repository "$Repository" --name "Downstream Merge" --from "$FromBranch" --to "$BRANCH" --reviewers "${BUILD_USER_ID}"
        fi
    else
        echo "Dry run - 'git push origin' skipped"
      fi
    else
      RESULT=3
      echo "********** Merge failed, creating pull request!"
      if [ "$DRYRUN" != "true" ]; then
        stash-cli  https://$bitbucket -a createPullRequest  --project "$Project" --repository "$Repository" --name "Downstream Merge Conflict Resolution" --from "$FromBranch" --to "$BRANCH" --reviewers "${BUILD_USER_ID}"
      else
        echo "(Dry run - pull request not created)"
      fi
    fi
  else
    echo "(branch skipped)"
  fi
  echo "---------- Processing complete for $Project/$Repository/$BRANCH"
done
if [ "$ToBranch" == "" ]; then
  echo "Target branch must be provided"
  RESULT=2
fi

echo ""

if [ "$RESULT" != "0" ]; then
  echo "One or more errors found; see log!"
fi

exit $RESULT
