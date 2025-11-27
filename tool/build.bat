@echo off
chcp 65001 >nul
setlocal

:: =================================================================
:: 配置区域: 请根据您的实际环境修改以下路径
:: =================================================================

:: 1. Markdown 笔记库 (mdbox) 的根目录
set "MDBOX_PATH=E:\learn\mdbox"
:: 2. Quartz 项目的根目录
set "QUARTZ_PATH=E:\Project\git\quartz"
:: 3. 需要从构建中排除的文件夹列表 (用空格分隔)
set "EXCLUDE_FOLDERS=.idea .obsidian tool 其他"
set "EXCLUDE_FILES=.gitignore"



:: =================================================================
:: 脚本主体: 一般无需修改以下内容
:: =================================================================
title Mdbox Build Script
echo.
echo [INFO] Mdbox 构建脚本启动...
echo [INFO] Markdown 库: %MDBOX_PATH%
echo [INFO] Quartz 项目: %QUARTZ_PATH%
echo.

:: --- 检查路径是否存在 ---
echo [CHECK] 验证路径...
powershell -Command "if (!(Test-Path '%MDBOX_PATH%')) { Write-Error 'Markdown库路径不存在'; exit 1 }"
if %errorlevel% neq 0 (
    echo [ERROR] Markdown 库路径不存在: %MDBOX_PATH%
    goto :end
)

powershell -Command "if (!(Test-Path '%QUARTZ_PATH%')) { Write-Error 'Quartz项目路径不存在'; exit 1 }"
if %errorlevel% neq 0 (
    echo [ERROR] Quartz 项目路径不存在: %QUARTZ_PATH%
    goto :end
)
echo [SUCCESS] 路径验证通过。
echo.

:: --- 步骤 1: 清理旧的构建产物和临时文件 ---
echo [STEP 1/5] 清理旧的构建产物...
powershell -Command "if (Test-Path '%MDBOX_PATH%\docs') { Write-Host '   - 删除 %MDBOX_PATH%\docs'; Remove-Item '%MDBOX_PATH%\docs' -Recurse -Force }"

powershell -Command "if (Test-Path '%QUARTZ_PATH%\public') { Write-Host '   - 删除 %QUARTZ_PATH%\public'; Remove-Item '%QUARTZ_PATH%\public' -Recurse -Force }"

powershell -Command "if (Test-Path '%QUARTZ_PATH%\content') { Write-Host '   - 删除 %QUARTZ_PATH%\content'; Remove-Item '%QUARTZ_PATH%\content' -Recurse -Force }"

echo [SUCCESS] 清理完成。
echo.

:: --- 步骤 2: 准备源文件 ---
echo [STEP 2/5] 复制源 Markdown 文件到 Quartz 项目...
powershell -Command "New-Item -ItemType Directory -Path '%QUARTZ_PATH%\content' -Force | Out-Null"

powershell -Command "Copy-Item '%MDBOX_PATH%\*' -Destination '%QUARTZ_PATH%\content' -Recurse -Force"

echo [SUCCESS] 文件复制完成。
echo.

:: --- 步骤 3: 排除不需要的文件夹和文件 ---
echo [STEP 3/5] 排除指定的文件夹和文件...
for %%d in (%EXCLUDE_FOLDERS%) do (
    powershell -Command "if (Test-Path '%QUARTZ_PATH%\content\%%d') { Write-Host '   - 排除文件夹: %%d'; Remove-Item '%QUARTZ_PATH%\content\%%d' -Recurse -Force }"
)

for %%f in (%EXCLUDE_FILES%) do (
    powershell -Command "if (Test-Path '%QUARTZ_PATH%\content\%%f') { Write-Host '   - 排除文件: %%f'; Remove-Item '%QUARTZ_PATH%\content\%%f' -Force }"
)

echo [SUCCESS] 排除完成。
echo.

:: --- 步骤 4: 运行 Quartz 构建命令 ---
echo [STEP 4/5] 使用 Quartz 生成静态网站...
cd /d "%QUARTZ_PATH%"
powershell -Command "& { Set-Location '%QUARTZ_PATH%'; npx quartz build -d content }"
if %errorlevel% neq 0 (
    echo [ERROR] Quartz 构建失败！请检查上面的错误信息。
    goto :end
)
echo [SUCCESS] Quartz 构建完成。
echo.

:: --- 步骤 5: 将构建好的网站移动到最终位置 ---
echo [STEP 5/5] 部署构建好的文件到 %MDBOX_PATH%\docs\
powershell -Command "New-Item -ItemType Directory -Path '%MDBOX_PATH%\docs' -Force | Out-Null"

powershell -Command "Move-Item '%QUARTZ_PATH%\public\*' -Destination '%MDBOX_PATH%\docs\' -Force"

echo [SUCCESS] 移动完成。
echo.

:: --- 结束 ---
echo =================================================================
echo [ALL DONE] Mdbox 构建成功！！！
echo =================================================================
echo.

:end
rem pause
rem endlocal