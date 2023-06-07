# これはなに？
AWSのFISを使い、スポットインスタンスを停止するチュートリアルです。  
Terraformで停止用のスポットインスタンスを即座に用意出来ます。

# 構成図
![](./pictures/FIS-Terminate-SpotInstance.drawio.png)

# 作成されるリソース
- ネットワーク一式
- スポットインスタンス(one-time)
- FIS用IAMロール
- FIS用CloudwatchLogグループ(`/fis/logs/`)

※実験テンプレートはawscliで用意します。  
※東京リージョンにリソースが作成されます。

# セットアップ手順
- `envs/dev`にて`terraform init`,`terraform apply`
- 実験テンプレート`envs/dev/template.json`から実験テンプレートを作成
  - AWSアカウントIDは補完すること

```bash
aws fis create-experiment-template --cli-input-json file://template.json
```

- 作成した実験テンプレートより実験を開始する
- スポットインスタンスが停止すること、CloudWatchLogsグループ(`/fis/logs/`)に実行ログが記録されることを確認する

# 片付け手順
- `terraform destroy`
- 実験テンプレートの削除

```bash
# テンプレートIDを出す
$ aws fis list-experiment-templates | jq -r '.experimentTemplates[].id'

# テンプレートIDを指定し、削除する
$ aws fis delete-experiment-template --id <ID>
```

# 注意
スポットインスタンスリクエストがスポットインスタンスを生成するまで時間があるため、
その間に`aws_ec2_tag`でタグ付けを行おうとして失敗します。(以下エラー参照)  
その際は再度`terraform apply`を実行して下さい。

```bash
│ Error: Missing required argument
│ 
│   with module.spot.aws_ec2_tag.tag,
│   on ../../modules/spot/main.tf line 66, in resource "aws_ec2_tag" "tag":
│   66:   resource_id = aws_spot_instance_request.test.spot_instance_id
│ 
│ The argument "resource_id" is required, but no definition was found.
```
