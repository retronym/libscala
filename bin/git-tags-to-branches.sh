#!/usr/bin/env bash
#
# turn remote git branches into tags and delete the remote branch

for branch in `git branch -r`; do
    if [ `echo $branch | egrep "tags/.+$"` ]; then
        version=`basename $branch`
        # subject=`git log -1 --pretty=format:"%s" $branch`
        # export GIT_COMMITTER_DATE=`git log -1 --pretty=format:"%ci" $branch`

        git tag -f -m "$version" "$version" "$branch"
        git branch -d -r $branch
    fi
done