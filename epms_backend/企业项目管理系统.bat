@echo off
echo 启动企业项目管理系统...

cd /d "D:\test\epms\epms_backend"

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo 未找到Python，请确保Python已安装并添加到系统路径
    pause
    exit /b 1
)

:: 获取以太网适配器 以太网中的IPv4地址
set "lan_ip="
for /f "tokens=1-2 delims=:" %%a in ('ipconfig ^| findstr /n "^"') do (
    set "line=%%b"
    if "%%b"==" 以太网适配器 以太网:" (
        set "found=1"
    ) else if defined found (
        echo "%%b" | findstr /c:"IPv4 地址" >nul && (
            for /f "tokens=2 delims=:" %%c in ("%%b") do (
                set "lan_ip=%%c"
                set "lan_ip=!lan_ip: =!"
                set "found="
            )
        )
    )
)

:: 确保获取到IP地址
::if not defined lan_ip (
  ::  echo 未找到以太网适配器 以太网的IPv4地址
    ::pause
    ::exit /b 1
::)

:: 启动Django开发服务器绑定到获取的IP
::start "" python manage.py runserver %lan_ip%:8000 --settings=epms_backend.settings.dev
start "" python manage.py runserver 0.0.0.0:8000 --settings=epms_backend.settings.dev

:: 等待服务器启动
timeout /t 8 /nobreak >nul

:: 打开系统前端页面
::start "" "http://127.0.0.1:8000/api/static/企业项目管理系统.html"
powershell -Command "Start-Process 'http://127.0.0.1:8000/api/static/企业项目管理系统.html'"

:menu
cls
echo ========================================
echo         企业项目管理系统控制台
echo ========================================
echo.
echo 运行状态: 运行中
echo 本地访问地址: http://127.0.0.1:8000/api/static/企业项目管理系统.html
::echo 局域网访问地址: http://%lan_ip%:8000/api/static/企业项目管理系统.html
echo 局域网访问地址: http://192.168.5.19:8000/api/static/企业项目管理系统.html
echo.
echo 可在终端用 ipconfig 实时查看此设备的局域网ipv4地址，替换192.168.5.19的位置
echo.
echo 请选择操作:
echo 1. 重新打开系统
echo 2. 查看运行日志
echo 3. 停止服务并退出
echo 4. 返回菜单(默认)
echo.
set /p choice=请输入选择 (1-4, 默认4): 

if "%choice%"=="1" (
    ::start "" "http://127.0.0.1:8000/api/static/企业项目管理系统.html"
    powershell -Command "Start-Process 'http://127.0.0.1:8000/api/static/企业项目管理系统.html'"
    echo 正在重新打开...
    timeout /t 2 >nul
    goto menu
) else if "%choice%"=="2" (
    echo 正在显示运行日志，按Ctrl+C可返回菜单...
    echo.
    python manage.py runserver --settings=epms_backend.settings.dev
    pause
    goto menu
) else if "%choice%"=="3" (
    echo 正在停止服务...
    taskkill /f /im python.exe >nul 2>&1
    echo 服务已停止，即将退出...
    pause >nul
    exit /b 0
) else (
    echo 即将返回菜单，5秒后...
    timeout /t 5 >nul
    goto menu
)
