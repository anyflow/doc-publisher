# manifest 작성 및 사용 가이드

## 기본 규칙

- directory 명으로 backend 구분
- `base.openapi.yaml` : environment 공통의 속성 정의 (파일명 변경 불가)
- `{environment}.openapi.yaml` : 해당 environment 별 속성 정의
- `apigw` directory에 포함된 environment 이외의 environment 정의는 무시됨
- `base.openapi.yaml` 가 따르는 규격
  - OpenAPI 3.0.3
  - TCN (***`base.openapi.yaml`의 TCN 규격 설명*** 섹션 참조)
  - krakend 최신 규격 (`apigw` 및 root에 위치한 `x-krakend` 항목의 경우)

## manifest directory 구조

  ```shell
  manifest
  ├── apigw                     # backend 공통 사항 정의 영역. (필수)
  │   ├── base.openapi.yaml     # backend 공통 사항 정의 파일. (필수)
  │   ├── local.openapi.yaml    # local environment overlay 파일
  │   └── prod.oepnapi.yam      # prod environment overlay 파일
  └── backend_1                 # backend 별 사항 정의 영역. backend_1은 해당 backend의 keyword.
      ├── base.openapi.yaml     # base (extended) openapi 파일
      ├── local.openapi.yaml    # local environment overlay 파일
      └── prod.oepnapi.yaml     # prod environment overlay 파일
  ```

## `base.openapi.yaml`의 TCN 규격 설명 : global 영역

> 각 항목에 대한 설명은 주석 참조. 주석 맨 앞에 '필수'가 있을 경우 해당 항목은 반드시 있어야 TCN 규격에 유효.

```yaml
x-tcn: # 필수. TCN 규격임을 나타냄
  app: dockebi # 필수. not null. backend를 나타내는 단일 word. 해당 파일이 포함된 directory 명과 동일해야 함.
  contacts: # 필수. not null. openapi.info.contact의 첫 번째 아이템으로 사용됨
    - name: 박연진 # 필수. not null.
      email: fake_yeonjin.park@lge.com # 필수. not null.
  openapiEndpoint: # 필수. not null. 본 파일에 기술되는 모든 openapi endpoint 설정에 반영되는 사항 모음
    urlPrefix: /dockebi # 필수. not null. 모든 openapi path 값 앞에 붙는 prefix
    parameters: # openapi의 path.{method}.parameters 참조
      - name: X-Dockebi-Region
        in: header
        schema:
          type: string
          example: f8f78c93-aec7-4d26-a3ab-cb263ddd08b1
  krakendEndpoint: # 필수. not null. 모든 krakend endpoint configuration에 반영되는 사항 모음
    # output_encoding: json # 기본값은 no-op. endpoints.output_encoding에 해당
    backend:
      host: dockebi.cluster.svc.cluster.local:8080 # 필수. not null. krakend configuartion의 backend.host 항목에 사용됨
      virtualhost: local.dockebi.com # 상기 host 이외의 host 및 해당 endpoint를 정의할 때 사용. krakend의 virtualhost 기능에 해당
      urlPatternPrefix: "/some_prefix" # 기본값은 "". url_pattern 기본값 앞에 붙는 prefix. url_pattern 기본값에는 openapi의 path 값이 사용됨.
      encoding: json # 기본 값은 no-op. backend.encoding 값에 해당
    extra_config: # krakend의 endpoints.backend.extra_config 참조.
      auth/api-keys:
        client_max_rate: 5
        roles:
          - dockebi
  global: # apigw backend 경우에만 유효 및 필수. 모든 backend의 endpoint에 적용되는 사항 모음.
    krakendIgnorePaths: # 필수. not null. openapi에 정의되어 있음에도 krakend configuration에 반영되지 않는 항목 목록
      - /__echo/{dummy}
    openapiEndpoint: # 필수. not null. x-tcn.openapiEndpoint와 동일하나 모든 backend에 적용됨
      security:
        - apiKeyAuth: []
      # parameters:
      #   - name: X-Trace-Id
      #     in: header
      #     schema:
      #       type: string
      #       example: "f8f78c93-aec7-4d26-a3ab-cb263ddd08b1"
    openapiComponents: # 필수. not null. 생성되는 모든 openapi.yaml에 적용되는 openapi의 components
      securitySchemes:
        apiKeyAuth:
          type: apiKey
          name: X-Api-Key
          in: header
    krakendEndpoint: # 필수. not null. x-tcn.krakendEndpoint와 동일하나 모든 backend에 적용됨
      input_headers:
        - Content-Type
        - X-Api-Key
      extra_config:
        auth/api-keys:
          roles:
            - admin


x-krakend: # apigw backend 경우에만 유효 및 필수.
...

openapi: 3.0.3 # 필수. version은 3.0.3으로 고정
info:
  title: Dockebi service # 필수. 연동규격에 보여질 서비스명
  description: |
    A service for TCN API Gateway testing   # 필수. 연동규격에 보여질 서비스 설명
paths: {} # 필수. OpenAPI 규격의 필수 입력 field로서, 없을 경우 {}를 사용
...
```

## `base.openapi.yaml`의 TCN 규격 설명 : endpoint별 설명

```yaml
paths:
  /v1/stuff:
    get:
      summary: List all stuffs or search stuffs by name
      ...
      x-tcn: # TCN 규격
        additionalPath: /addtional/some/path # 지정된 endpoint에 대한 추가 주소.
        virtualhostPath: /legacy/stuff # 지정된 endpoint에 대한 virtualhost 상의 path. 본 값 지정 시 global 영역의 x-tcn.krakendEndpoint.backend.virtualhost가 반드시 정의되어 있어야 함.
      x-krakend: # Krakend 규격(TCN 규격 확장). 본 항목에서 정의되는 속성은 자동 생성되는 속성을 override함.
        input_headers: ["*"] # 수신할 request header 목록. *은 전체 header를 수신함을 의미
        extra_config:
          "@test_extra_config": extra_config_in_endpoint
          auth/api-keys:
            roles:
              - testRole # 호출 가능한 role 추가 시 사용 (API KEY에 role이 정의됨)
            client_max_rate: 10 # API KEY 별 second당 호출 가능 횟수 지정
```
