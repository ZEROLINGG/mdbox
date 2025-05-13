# ZEROLINGG/mdbox - 多领域知识库笔记

## 介绍

欢迎来到 `mdbox` 知识库！本仓库用于整理和归档多个技术方向的学习笔记，涵盖编程语言、网络安全、CTF、数据库等主题。所有内容都以 Markdown 形式编写，并适配 Obsidian 使用。

### 主要分类

- **编程语言**: Python、Java、C/C++、汇编
- **网络安全**: Web 安全、KALI、CTF 题解
- **脚本语言**: PowerShell、VBScript、JavaScript
- **数据库**: MySQL、其他数据库相关知识

## 协作指导

### 如何参与

1. **Fork 仓库**:
   - 点击右上角的 **Fork** 按钮，创建仓库的副本到你自己的 GitHub 账户中。
   - 在你的 GitHub 账户中，你将拥有该仓库的完整控制权限，可以自由修改。

2. **克隆仓库到本地**:
   - 通过 Git 将仓库克隆到你本地的计算机，以便进行更改：
     ```bash
     git clone https://github.com/ZEROLINGG/mdbox.git
     ```
   

3. **创建新分支**:
   - 在进行修改之前，你可以选择创建一个新的分支以避免直接修改主分支。分支名称应简洁且有描述性。
     ```bash
     git checkout -b one
     ```
   - one 替换为你要进行的修改或新增功能的名称。

4. **编辑文档**:
   - 使用你熟悉的编辑器（如 **Obsidian** 或 **Visual Studio Code**）打开 `.md` 文件进行修改。可以在各个分类下添加新的内容、更新现有文档或修正拼写错误。
   - 确保所有新内容都符合现有的文档结构和格式。

5. **提交更改**:
   - 在本地提交你的更改时，确保提交信息简洁明了，并准确描述修改内容。遵循 [Commit Message Convention](https://www.conventionalcommits.org/) 规范：
     ```bash
     git add .
     git commit -m "添加了新的知识"
     ```

6. **推送更改**:
   - 将修改推送到 GitHub 仓库中：
     ```bash
     git push -u origin main
     ```
   - 推送后，你可以在 GitHub 仓库中看到你的修改已上传。

7. **提交 Pull Request**:
   - 在 GitHub 上打开你的仓库，点击 **Pull Requests**，然后点击 **New Pull Request**。
   - 选择你刚才创建的分支（如果创建了）和主仓库的 `main` 分支进行对比。
   - 在提交 Pull Request 时，确保说明清楚你所做的更改和修改的目的。例如：
     ```
     添加 Python 基础知识部分，并更新了部分格式。
     修正了 C++ 部分的拼写错误。
     ```

8. **审查与合并**:
   - 项目维护者定期审查 Pull Request。在合并之前，确保所有修改通过了检查并且没有引入任何不一致的格式或错误。
   - 如果有任何问题或需要改进的地方，会要求修改并重新提交。

### 协作规则与最佳实践

1. **命名规范**:
   - 在创建分支时，请使用简短且有描述性的名称，说明所做的修改内容。例如，`add-python-functions`，`fix-markdown-syntax`。
   
2. **文档格式与一致性**:
   - 请严格遵循 Markdown 格式，保持文档的简洁性和清晰性。你可以参考已有文档的格式。
   - 对于代码片段，可以使用 ``` 代码块 语法，确保代码可读性：
     ```python
     def hello_world():
         print("Hello, world!")
     ```

3. **详细的提交信息**:
   - 提交信息应简洁且描述明确。避免使用含糊不清的提交信息（如 `fix bug`，`update files`），应具体说明修改的内容（如 `修复 Python 示例代码中的错误`，`更新 MySQL 连接配置部分`）。

4. **Pull Request 审查**:
   - 提交 Pull Request 后，等待项目维护者审查并合并。如果有反馈，及时进行修改并更新 PR。
   - 记得在提交 PR 后留意评论和审查建议，及时回复和调整。

5. **避免直接在 `main` 分支上进行修改**:
   - 所有更改都应通过新建分支并提交 Pull Request 的方式进行，这样可以确保仓库的稳定性。

### 问题反馈与讨论

1. **报告问题**:
   - 如果你在使用过程中发现问题，或在修改过程中遇到障碍，可以使用 **Issues** 功能报告问题。
   - 在仓库的 **Issues** 页面，点击 **New Issue**，并提供详细的问题描述，附带错误日志、截图或复现步骤。

2. **讨论与提问**:
   - 如果你有任何疑问或想要与其他人讨论某个问题，可以在仓库的 **Discussions** 中发起讨论。
   - 在 **Discussions** 页面，选择 **New Discussion**，并选择讨论类型（如问题、提案等）。

3. **标签使用**:
   - 为 Issues 和 Pull Requests 添加适当的标签，例如 `bug`、`enhancement`、`question` 等，以便分类管理。

### 其他资源

- **Obsidian**: 本仓库中的笔记适合使用 [Obsidian](https://obsidian.md/) 打开，以便获得最佳的浏览体验和图谱功能。
- **Markdown 语法**: 如果你不熟悉 Markdown 格式，可以参考 [Markdown 官方文档](https://www.markdownguide.org/) 和[Markdown 菜鸟教程](https://www.runoob.com/markdown/md-title.html)进行学习。

## 贡献者

感谢每一位参与者，你的贡献对本项目至关重要！通过大家的共同努力，我们的知识库将不断完善，并帮助更多学习者。

---

> **注意**: 请在进行任何修改之前，先确保自己理解当前文档的内容，并尽量避免对已有内容做不必要的更改。如果有疑问或不确定的地方，请随时在 Issues 或 Discussions 中提问。
