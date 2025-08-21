<#
.SYNOPSIS
    Obsidian을 위한 SQL 학습 구조(MOC - Map of Contents)를 생성합니다.
.DESCRIPTION
    지정된 루트 경로에 SQL 학습을 위한 폴더와 마크다운(.md) 파일들을 체계적으로 생성합니다.
    중첩된 폴더 구조를 포함하여 제공된 전체 커리큘럼을 반영합니다.
    모든 파일의 확장자는 Obsidian에서 바로 사용할 수 있도록 '.md'로 통일됩니다.
.NOTES
    Author: Gemini
    Date: 2025-08-18
    실행 방법:
    1. 이 스크립트 파일을 원하는 곳에 저장합니다 (예: Create-SQL-MOC.ps1).
    2. 파일 저장 시 인코딩을 'UTF-8'로 설정해야 한글 파일 이름이 깨지지 않습니다.
    3. 파일에 마우스 오른쪽 버튼을 클릭하고 'PowerShell에서 실행'을 선택합니다.
    4. 또는 PowerShell 터미널에서 `.\Create-SQL-MOC.ps1`을 입력하여 실행합니다.
#>

# --- 설정: 루트 경로 지정 ---
$rootPath = "H:\내 드라이브\Obsidian 보관소\obsi-moc-5\40-knowledge-resources-input\41-computer-science\41-30-Software-Engineering\41-31-Programming-Language\5-SQL"

# --- 구조 정의: 폴더(Key)와 그 안의 MD 파일 목록(Value) ---
# 중첩된 폴더 구조를 위해 재귀적으로 처리할 수 있는 해시 테이블을 사용합니다.
$structure = @{
    "00_Mindset_and_Setup"                = @(
        "00.1_RDBMS_vs_NoSQL.md",
        "00.2_Database_Types.md",
        "00.3_Setup_with_Docker.md",
        "00.4_Setup_GUI_Clients.md"
    );
    "01_Data_Query_Language_DQL"          = @(
        "01.1_SELECT_FROM_AS.md",
        "01.2_WHERE_Filtering.md",
        "01.3_ORDER_BY_LIMIT_OFFSET.md",
        "01.4_Basic_Functions.md",
        "01.5_CASE_Statements.md"
    );
    "02_Data_Manipulation_and_Definition" = @(
        "02.1_INSERT_INTO.md",
        "02.2_UPDATE_DELETE_TRUNCATE.md",
        "02.3_CREATE_ALTER_DROP_TABLE.md",
        "02.4_Data_Types_and_Constraints.md"
    );
    "03_Intermediate_Querying"            = @(
        "03.1_Aggregate_Functions.md",
        "03.2_GROUP_BY_and_HAVING.md",
        "03.3_JOINs.md",
        "03.4_Subqueries_and_EXISTS.md"
    );
    "04_Advanced_SQL"                     = @(
        "04.1_Window_Functions.md",
        "04.2_Common_Table_Expressions_CTEs.md",
        "04.3_Views_and_Stored_Procedures.md",
        "04.4_Transactions.md",
        "04.5_Indexes_and_Query_Planning.md"
    );
    "05_Database_Design_and_Ecosystem"    = @(
        "05.1_Normalization_and_ERD.md",
        "05.2_Keys_and_Relationships.md",
        "05.3_Understanding_ORMs.md",
        "05.4_Database_Migration_Tools.md"
    );
    "06_Connecting_with_Languages"        = @{
        "06.1_Python_Integration"                = @(
            "06.1.1_DB-API_with_psycopg2.md",
            "06.1.2_SQLAlchemy_and_Pandas.md"
        );
        "06.2_JavaScript_TypeScript_Integration" = @(
            "06.2.1_Node-Postgres_and_Knex.md",
            "06.2.2_Prisma_ORM.md"
        );
        "06.3_Go_Integration"                    = @(
            "06.3.1_database_sql_and_sqlc.md"
        );
        "06.4_Rust_Integration"                  = @(
            "06.4.1_SQLx_and_Diesel.md"
        );
        "06.5_CLI_and_Scripting_Integration"     = @(
            "06.5.1_PowerShell_Invoke-Sqlcmd.md",
            "06.5.2_Bash_with_psql.md"
        )
    };
    "07_Capstone_Project"                 = @(
        "07.1_Design_and_Build_Schema.md",
        "07.2_Implement_API_with_Python.md"
    )
}

# --- 실행: 폴더 및 파일 생성 (재귀 함수 사용) ---

function New-StructureFromMap {
    param(
        [string]$currentPath,
        [System.Collections.IDictionary]$structureMap
    )

    foreach ($entry in $structureMap.GetEnumerator()) {
        $itemPath = Join-Path -Path $currentPath -ChildPath $entry.Key
        
        # 값이 배열이면(파일 목록), 폴더를 만들고 그 안에 파일을 생성
        if ($entry.Value -is [System.Array]) {
            New-Item -ItemType Directory -Path $itemPath -ErrorAction SilentlyContinue | Out-Null
            Write-Host "  [폴더] $($itemPath.Replace($rootPath, ''))"
            
            foreach ($file in $entry.Value) {
                $filePath = Join-Path -Path $itemPath -ChildPath $file
                New-Item -ItemType File -Path $filePath -ErrorAction SilentlyContinue | Out-Null
                Write-Host "    └ [파일] $file"
            }
        }
        # 값이 해시 테이블이면(하위 폴더 목록), 재귀적으로 함수 호출
        elseif ($entry.Value -is [System.Collections.IDictionary]) {
            New-Item -ItemType Directory -Path $itemPath -ErrorAction SilentlyContinue | Out-Null
            Write-Host "  [폴더] $($itemPath.Replace($rootPath, ''))"
            
            # 재귀 호출
            New-StructureFromMap -currentPath $itemPath -structureMap $entry.Value
        }
    }
}

Write-Host "SQL 학습 구조 생성을 시작합니다..."
Write-Host "대상 경로: $rootPath"

# 루트 폴더가 없으면 생성
if (-not (Test-Path -Path $rootPath)) {
    New-Item -ItemType Directory -Force -Path $rootPath | Out-Null
    Write-Host "[생성] 루트 폴더: $rootPath"
}

# 정의된 구조에 따라 폴더 및 파일 생성 시작
New-StructureFromMap -currentPath $rootPath -structureMap $structure

# 루트 경로에 README.md 파일 생성
New-Item -ItemType File -Path (Join-Path -Path $rootPath -ChildPath "README.md") -ErrorAction SilentlyContinue | Out-Null
Write-Host "  [파일] \README.md"

Write-Host "`n모든 폴더와 파일 생성이 완료되었습니다."
# 생성된 폴더 탐색기에서 열기 (주석 해제 시 활성화)
# explorer.exe $rootPath