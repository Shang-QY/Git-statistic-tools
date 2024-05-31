#!/bin/bash

branch1=$1
branch2=$2

# 找到分叉点
merge_base=$(git merge-base $branch1 $branch2)

# 获取所有包含"Fusa"的提交哈希
commit_hashes=$(git log --grep=Fusa -i --format=format:%H $merge_base..$branch1)

# 为每个提交获取改动的文件列表
for commit in $commit_hashes; do
    git show --name-only --format="" $commit
done | sort | uniq

