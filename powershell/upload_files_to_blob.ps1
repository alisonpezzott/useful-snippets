@echo off
REM ====== CONFIG ======
set ACCOUNT=<sua-conta>                 REM sem .blob.core...
set CONTAINER=<seu-container>
set PREFIX=<prefixo-opcional>           REM ex: logs/ ou deixe vazio
set LOCAL_ROOT=C:\dados\logs            REM pasta raiz local (onde estão 2025/2025-Q3/...)
REM ====== EXEC ======
azcopy copy "%LOCAL_ROOT%" "https://%ACCOUNT%.blob.core.windows.net/%CONTAINER%/%PREFIX%" --recursive=true --log-level=INFO
