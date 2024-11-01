@ECHO OFF
set SOURCE_GITLAB_REPO_URL=ssh://git@gitlab.syntecclub.com:40022/ProjectRoot/CNC/appkernel.git
set TARGET_GITLAB_REPO_URL=ssh://git@gitlab.syntecclub.com:40022/ProjectRoot/AUTO/lasercutting/laser-cutting-plugin.git
set FILTER_SOURCE_REPO_DIR=PlugIn/LaserCutting/NewCutting/
set PROJECT_NAME=LaserCuttingTest
set PUTTYKEY_PATH=C:\Users\OpenCNC\.ssh\gitlab_rsa.ppk

ECHO clone the source gitlab repo to local
git clone %SOURCE_GITLAB_REPO_URL% %PROJECT_NAME%
pushd %PROJECT_NAME%

ECHO re-add remote
git remote rm origin
git remote add origin %SOURCE_GITLAB_REPO_URL%
git config --local remote.origin.puttykeyfile %PUTTYKEY_PATH%
git fetch

ECHO extract directory want to be saved
git filter-repo --subdirectory-filter %FILTER_SOURCE_REPO_DIR% --force

ECHO re-add remote
git remote rm origin
git remote add origin %TARGET_GITLAB_REPO_URL%
git config --local remote.origin.puttykeyfile %PUTTYKEY_PATH%
git fetch

ECHO push all local branches to new repo
git push --set-upstream origin master --no-verify
REM git push --all --no-verify

setlocal enabledelayedexpansion
for /f "delims=" %%b in ('git for-each-ref --format="%%(refname:short)" --sort=-committerdate refs/heads/') do (
    set "branch=%%b"
    echo push dir: !branch!
    git push origin !branch!  --no-verify
)
endlocal

popd
pause