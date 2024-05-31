import git
from openpyxl import Workbook
from openpyxl.styles import Alignment
from openpyxl.utils import get_column_letter

# 配置
repo_path = 'Intel'  # 你的Git仓库路径
input_file = 'cherry-pick-progress.txt'  # 包含提交哈希的文本文件
output_file = 'commits-new2.xlsx'  # 输出的Excel文件

# 初始化Git仓库
repo = git.Repo(repo_path)

# 创建一个新的Excel工作簿
wb = Workbook()
ws = wb.active
ws.title = "Commits"

# 设置Excel表头
headers = ['Commit Hash', 'Commit Message Title', 'Detailed Commit Message', 'Modified Files']
ws.append(headers)

# 读取提交哈希列表
with open(input_file, 'r') as file:
    commit_hashes = [line.strip() for line in file if line.strip()]

# 查询每个提交的详细信息
for commit_hash in commit_hashes:
    try:
        commit = repo.commit(commit_hash)
        commit_message_title = commit.message.strip().split('\n')[0]  # 获取提交消息的第一行
        detailed_commit_message = commit.message.strip()  # 获取完整的提交消息
        # 获取修改的文件列表及其统计数据
        modified_files_stats = []
        for file_path, stats in commit.stats.files.items():
            modified_files_stats.append(f"{file_path} (+{stats['insertions']}/-{stats['deletions']})")
        modified_files = '\n'.join(modified_files_stats)  # 每个文件后换行
        ws.append([commit_hash, commit_message_title, detailed_commit_message, modified_files])
        # 获取当前行号
        current_row = ws.max_row
        # 设置单元格的自动换行
        for col in range(1, len(headers) + 1):
            ws.cell(row=current_row, column=col).alignment = Alignment(wrap_text=True)
    except Exception as e:
        print(f"Error processing commit {commit_hash}: {e}")

# 调整列宽
for column in ws.columns:
    max_length = 0
    column = [cell for cell in column]
    for cell in column:
        try:
            if len(str(cell.value)) > max_length:
                max_length = len(cell.value)
        except:
            pass
    adjusted_width = (max_length + 2)
    ws.column_dimensions[get_column_letter(column[0].column)].width = adjusted_width

# 保存Excel文件
wb.save(filename=output_file)
print(f"Excel file '{output_file}' has been created with commit details.")