@echo off
set TEXCONV="D:\texconv\texconv.exe"

for %%f in (*.png) do (
    echo Converting %%f ...
    %TEXCONV% -f BC3_UNORM -nologo -y -m 1 -ft dds -o . "%%f"
)

echo Done!
pause