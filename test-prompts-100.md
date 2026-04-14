# Genie Code + AI Dev Kit MCP 테스트 프롬프트 100선

> Genie Code OOB로는 처리 불가하지만, AI Dev Kit MCP 도구를 활성화하면 처리 가능한 프롬프트

---

## Genie Space 생성/관리 (`manage_genie`)

1. gold 스키마의 regional_kpis, customer_360_v2 테이블로 새 Genie Space 만들어줘
2. 이 워크스페이스에 있는 Genie Space 목록 보여줘
3. LG D2C Intelligence Genie Space에 inventory_alerts 테이블 추가해줘
4. Genie Space 설명을 "LG전자 D2C 글로벌 분석 허브"로 수정해줘
5. 기존 Genie Space를 export해서 다른 워크스페이스로 마이그레이션할 수 있게 해줘
6. sample question 5개를 Genie Space에 추가해줘
7. 테스트용으로 만든 Genie Space 삭제해줘
8. Genie Space에 연결된 테이블 목록 확인해줘
9. customer_360_v2 테이블 하나만으로 간단한 Genie Space 만들어줘
10. 현재 Genie Space의 warehouse를 다른 걸로 변경해줘

## Supervisor Agent / MAS (`manage_mas`)

11. CFO Analytics Genie + Document KA를 묶은 Supervisor Agent 만들어줘
12. 현재 워크스페이스의 Supervisor Agent 목록 보여줘
13. Supervisor Agent에 새로운 sub-agent 추가해줘
14. Supervisor Agent의 instructions를 한국어 응답 우선으로 수정해줘
15. Supervisor Agent에 라우팅 예제 3개 추가해줘
16. Supervisor Agent 엔드포인트 상태 확인해줘
17. Supervisor Agent를 모든 워크스페이스 사용자에게 공유해줘
18. Supervisor Agent의 sub-agent 중 하나를 제거해줘
19. Supervisor Agent에 "재무 질문은 CFO Genie로" 라우팅 규칙 추가해줘
20. 테스트용 Supervisor Agent 삭제해줘

## Knowledge Assistant / KA (`manage_ka`)

21. /Volumes/main/docs/에 있는 PDF 문서들로 Knowledge Assistant 만들어줘
22. KA 엔드포인트가 ONLINE 상태인지 확인해줘
23. KA에 학습 예제 질문 5개 추가해줘
24. KA의 knowledge source에 새 Volume 경로 추가해줘
25. KA에게 "ESG 2030 목표가 뭐야?" 질문해줘
26. KA의 instructions를 수정해서 항상 출처를 인용하도록 해줘
27. 현재 워크스페이스의 KA 목록 보여줘
28. KA 엔드포인트 이름 확인해줘
29. KA를 특정 사용자 그룹에게만 공유해줘
30. 테스트용 KA 삭제해줘

## Job 생성/관리 (`manage_jobs`)

31. 매일 오전 9시 KST에 gold 테이블을 refresh하는 Job 만들어줘
32. 현재 워크스페이스의 Job 목록 보여줘
33. daily-refresh Job의 스케줄을 매시간으로 변경해줘
34. 노트북 /Users/me/etl_pipeline.py를 실행하는 Job 만들어줘
35. Job에 실패 시 이메일 알림 설정 추가해줘
36. 특정 Job을 비활성화(pause)해줘
37. Job의 클러스터 설정을 serverless로 변경해줘
38. Job에 retry policy 3회 설정해줘
39. 2개 task를 순차 실행하는 multi-task Job 만들어줘
40. 테스트용 Job 삭제해줘

## Job 실행/모니터링 (`manage_job_runs`)

41. daily-refresh Job을 지금 바로 실행해줘
42. 현재 실행 중인 Job run 목록 보여줘
43. 마지막 Job run의 상태와 결과 확인해줘
44. 실패한 Job run의 에러 로그 보여줘
45. 특정 Job의 최근 10개 실행 이력 보여줘
46. 현재 실행 중인 Job run을 취소해줘
47. Job run의 실행 시간과 성능 통계 보여줘
48. 실패한 Job을 파라미터 변경해서 다시 실행해줘
49. 특정 날짜 범위의 Job 실행 이력 보여줘
50. Job run output 결과값 확인해줘

## Dashboard 생성 (`manage_dashboard`) — 크로스 프로덕트

51. 노트북에서 분석한 regional_kpis 데이터로 대시보드 만들어줘
52. 지역별 매출 bar chart + 월별 추이 line chart가 있는 대시보드 만들어줘
53. customer_360_v2의 churn risk 분포를 보여주는 대시보드 만들어줘
54. 기존 대시보드에 새 위젯 추가해줘
55. 대시보드를 publish해서 다른 사용자가 볼 수 있게 해줘
56. 현재 워크스페이스의 대시보드 목록 보여줘
57. 대시보드의 SQL 쿼리를 최적화해줘
58. 2개 테이블을 JOIN해서 대시보드 만들어줘
59. 대시보드를 삭제해줘
60. 대시보드의 데이터소스 warehouse를 변경해줘

## Pipeline 관리 (`manage_pipeline`)

61. bronze → silver → gold 패턴의 DLT 파이프라인 만들어줘
62. 현재 워크스페이스의 파이프라인 목록 보여줘
63. 파이프라인 설정에서 target schema를 변경해줘
64. 파이프라인에 새 notebook을 library로 추가해줘
65. 파이프라인의 클러스터 설정을 수정해줘
66. continuous 모드 파이프라인을 triggered 모드로 변경해줘
67. 파이프라인을 삭제해줘
68. 파이프라인 이벤트 로그 보여줘
69. 파이프라인 실행해줘
70. 실행 중인 파이프라인 중지해줘

## Apps 관리 (`manage_app`)

71. 현재 워크스페이스에 배포된 앱 목록 보여줘
72. mcp-ai-dev-kit 앱의 상태와 URL 확인해줘
73. 앱의 최근 배포 로그 보여줘
74. 앱을 재배포해줘
75. 새 Databricks App을 생성해줘
76. 앱을 중지해줘
77. 앱의 환경변수 설정 확인해줘

## Lakebase (`manage_lakebase_database`)

78. 새 Lakebase PostgreSQL 데이터베이스 만들어줘
79. Lakebase 인스턴스 목록 보여줘
80. Lakebase 연결 credential 생성해줘
81. Lakebase 브랜치 만들어줘
82. Lakebase 데이터베이스 삭제해줘

## Model Serving (`manage_serving_endpoint`)

83. 서빙 엔드포인트 목록 보여줘
84. 특정 서빙 엔드포인트의 상태 확인해줘
85. 서빙 엔드포인트에 쿼리 보내줘
86. 엔드포인트의 트래픽 설정 변경해줘
87. 서빙 엔드포인트의 로그 확인해줘

## UC 관리 (`manage_uc_objects`, `manage_uc_grants`)

88. 새 카탈로그 만들어줘
89. gold 스키마에 새 테이블 생성해줘
90. 특정 사용자에게 gold 스키마 SELECT 권한 부여해줘
91. 카탈로그의 모든 스키마 목록 보여줘
92. 테이블의 owner를 변경해줘
93. 스키마에 태그 추가해줘
94. 특정 사용자의 현재 권한 확인해줘
95. Volume 생성해줘

## 코드 실행 / 파일 관리 (`execute_code`, `manage_workspace_files`)

96. 클러스터에서 Python 스크립트 실행해줘
97. PySpark로 테이블 데이터 변환 코드 실행해줘
98. 워크스페이스에 새 노트북 파일 업로드해줘
99. /Workspace/Users/me/ 아래 파일 목록 보여줘
100. 워크스페이스 파일을 로컬로 다운로드해줘
