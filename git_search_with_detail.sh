#!/bin/bash

branch1=$1
branch2=$2

# 找到分叉点
merge_base=$(git merge-base $branch1 $branch2)

# 获取所有包含"Fusa"的提交哈希
commit_hashes=$(git log --grep=Fusa -i --format=format:%H $merge_base..$branch1)

# 为每个提交获取改动的文件列表及其统计数据
for commit in $commit_hashes; do
    echo "Commit: $commit"
    git show --numstat --format="" $commit | awk '
    {
        if ($1 == "-" && $2 == "-") {
            print $3 " ADD";
        } else {
            added_lines = ($1 != "-" ? $1 : 0);
            deleted_lines = ($2 != "-" ? $2 : 0);
            print $3 " " added_lines "/" deleted_lines;
        }
    }'
done

