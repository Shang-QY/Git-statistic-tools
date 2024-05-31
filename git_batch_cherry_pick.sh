#!/bin/bash

branch1=$1
branch2=$2

# 定义一个文件来保存cherry-pick的进度
progress_file="../cherry-pick-progress.txt"

# 确保没有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: Working directory is not clean. Please commit or stash your changes."
  exit 1
fi

# 切换到目标分支 branch2
git checkout $branch2 || exit

# 找到分叉点
merge_base=$(git merge-base $branch1 $branch2)

# 如果进度文件存在，则读取已经cherry-picked的提交哈希
if [ -f "$progress_file" ]; then
  readarray -t completed_commits < "$progress_file"
else
  completed_commits=()
fi

# 获取所有包含"Fusa"的提交哈希
commit_hashes=$(git log --reverse --grep=Fusa -i --format=format:%H $merge_base..$branch1)

# Cherry-pick每个提交到当前分支 branch2
for commit in $commit_hashes; do
  # 检查提交是否已经cherry-picked
  if printf '%s\n' "${completed_commits[@]}" | grep -q "^$commit$"; then
    echo "Skipping already cherry-picked commit $commit"
    continue
  fi

  if git cherry-pick $commit; then
    echo "Cherry-picked commit $commit"
    # 将成功的提交哈希添加到进度文件
    echo $commit >> "$progress_file"
  else
    echo "Cherry-pick conflict detected for commit $commit. Attempting to auto-resolve..."
    # 尝试自动解决冲突，接受所有incoming更改
    git checkout --theirs .
    git add .
    if git cherry-pick --continue; then
      echo "Conflict resolved for commit $commit, cherry-pick continued."
      echo $commit >> "$progress_file"
    else
      echo "Error: Auto-resolve failed for commit $commit. Manual resolution required."
      exit 1
    fi
  fi
done

echo "All selected commits from branch1 have been cherry-picked onto branch2."
