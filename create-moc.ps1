<#
.DESCRIPTION
    이 파일은 실행 로직 전용입니다. 이 파일은 수정할 필요가 없습니다. MocConfig.ps1 파일을 불러와서 정의된 구조대로 파일과 폴더를 생성하는 역할만 합니다.


    
.SYNOPSIS
    'MocConfig.ps1' 설정 파일을 읽어 MOC 디렉터리 구조를 생성합니다.

.DESCRIPTION
    이 스크립트를 실행하면, 동일한 폴더에 있는 'MocConfig.ps1' 파일의
    $BusinessMocStructure 변수와 $rootPath 변수를 가져와서
    실제 디렉터리와 파일을 생성합니다.

.WARNING
    이 스크립트는 실제 파일과 폴더를 디스크에 생성합니다. 'MocConfig.ps1'의 $rootPath를 정확히 확인하세요.

.NOTES
    Author: Gemini
    Date: 2025-08-19
#>

# --- 1. 설정 파일 불러오기 (Import Configuration) ---
try {
    # $PSScriptRoot는 현재 실행 중인 스크립트가 위치한 디렉터리를 의미합니다.
    # 이를 통해 항상 스크립트와 같은 위치에 있는 설정 파일을 정확히 찾을 수 있습니다.
    . "$PSScriptRoot\MocConfig.ps1"
}
catch {
    Write-Error "설정 파일(MocConfig.ps1)을 찾을 수 없거나 불러오는 중 오류가 발생했습니다."
    Write-Error "이 스크립트와 동일한 폴더에 MocConfig.ps1 파일이 있는지 확인하세요."
    # 설정 파일을 불러오지 못하면 스크립트를 중단합니다.
    return
}


# --- 2. 디렉터리 및 파일 생성 로직 ---

# 중첩된 해시테이블 구조를 처리하기 위한 재귀 함수 정의
function New-MocStructure {
    param (
        [string]$CurrentPath,
        [System.Collections.Hashtable]$StructureData
    )

    foreach ($item in $StructureData.GetEnumerator()) {
        $itemName = $item.Name
        $itemValue = $item.Value
        $newPath = Join-Path -Path $CurrentPath -ChildPath $itemName

        if ($itemValue -is [System.Collections.Hashtable]) {
            Write-Host "📁 Creating Directory: $newPath"
            New-Item -Path $newPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
            New-MocStructure -CurrentPath $newPath -StructureData $itemValue
        }
        elseif ($itemValue -is [System.Array]) {
            Write-Host "📁 Creating Directory: $newPath"
            New-Item -Path $newPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
            foreach ($fileName in $itemValue) {
                $filePath = Join-Path -Path $newPath -ChildPath $fileName
                Write-Host "  📄 Creating File: $filePath"
                New-Item -Path $filePath -ItemType File -Force | Out-Null
            }
        }
    }
}


# --- 3. 스크립트 실행 ---

# 최상위 루트 디렉터리가 없으면 생성
if (-not (Test-Path -Path $rootPath)) {
    Write-Host "🚀 Root directory not found. Creating: $rootPath" -ForegroundColor Yellow
    New-Item -Path $rootPath -ItemType Directory -Force | Out-Null
}

Write-Host "--- Starting MOC structure creation in '$rootPath' ---" -ForegroundColor Green

# 정의된 구조를 기반으로 파일 및 폴더 생성 시작
New-MocStructure -CurrentPath $rootPath -StructureData $BusinessMocStructure

Write-Host "--- ✨ All directories and files created successfully! ---" -ForegroundColor Green