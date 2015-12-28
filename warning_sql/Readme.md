#Warning_SQL
Sourcemod를 지원하는 모든 게임에서 지원합니다.
또한 Ban 함수를 쓰지 않고 서버측에서 명령어를 입력하게 되어, 
소스밴 목록에도 추가가 자동적으로 됩니다.

#사용법
사용법: sourcemod\configs\databases.cfg파일에서 
```C
"superban"
 {
  "driver"   "default"
  "host"    "localhost"
  "database"   "데베이름"
  "user"    "유저이름"
  "pass"    "비번"
  //"timeout"   "0"
  "port"   "3306"
 }
```
 를 추가해주시면 됩니다.
 
 명령어는 !warning "이름" "경고량"
또는 콘솔에서 sm_warning "이름" "경고량"

일반 영구밴하고 다른점은 경고를 여러번 받으면 밴당하는 점입니다.
