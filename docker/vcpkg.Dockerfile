# Vcpkg dependency installation for Windows builds
FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install git
RUN choco install -y git --no-progress

# Clone and bootstrap vcpkg
WORKDIR C:/vcpkg
RUN git clone https://github.com/Microsoft/vcpkg.git . && \
    .\bootstrap-vcpkg.bat

# Install all required dependencies
RUN .\vcpkg.exe install gflags:x64-windows && \
    .\vcpkg.exe install sqlite3:x64-windows && \
    .\vcpkg.exe install detours:x64-windows && \
    .\vcpkg.exe install gtest:x64-windows && \
    .\vcpkg.exe install libvpx:x64-windows && \
    .\vcpkg.exe install opus:x64-windows && \
    .\vcpkg.exe install fftw3:x64-windows && \
    .\vcpkg.exe install easyhook:x64-windows && \
    .\vcpkg.exe install glm:x64-windows && \
    .\vcpkg.exe install sdl2:x64-windows && \
    .\vcpkg.exe install jemalloc:x64-windows && \
    .\vcpkg.exe install protobuf:x64-windows && \
    .\vcpkg.exe install asio:x64-windows && \
    .\vcpkg.exe install openssl:x64-windows && \
    .\vcpkg.exe install ffmpeg:x64-windows && \
    .\vcpkg.exe install opencv:x64-windows && \
    .\vcpkg.exe install cpr:x64-windows

# Set environment variables
ENV VCPKG_ROOT=C:/vcpkg
ENV VCPKG_DEFAULT_TRIPLET=x64-windows

# Verify installation
RUN .\vcpkg.exe list

WORKDIR C:/
CMD ["powershell"]