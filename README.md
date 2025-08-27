<p align="center">
  <h1 align="center">특수기능을 포함한 스마트 도어락 설계✨</h1>
  <img width="1276" height="622" alt="Simulation_Full_Screen" src="https://github.com/user-attachments/assets/1e176748-8a40-4256-83f3-a1216642ce5a" />
</p>

## Index ⭐️
- [1. 프로젝트 목표](#프로젝트-목표) <br/>
- [2. 스마트 도어락 모듈](#스마트-도어락-모듈) <br/>
- [3. 모듈 테스트 및 분석](#모듈-테스트-및-분석) <br/>
- [4. 결론](#결론) <br/>

## 프로젝트 목표
&nbsp;본 프로젝트는 Verilog HDL을 활용하여 하드웨어에 최적화된 저전력 스마트 도어락을 설계하는 것을 목표로 합니다. <br/>
특히, 지문 자국을 통한 외부 침입을 방지하기 위해 터치스크린 방식의 동적 키패드 디스플레이를 가정하며, 기존 도어락에 없는 특수 기능을 포함합니다. <br/>
주요 추가 기능으로는 매번 숫자판 디스플레이가 변경되는 '동적 키패드 디스플레이', 문이 열리면 만료되는 '임시 비밀번호', 5회 연속 비밀번호 오류 시 울리는 '경보 기능', 특정 버튼을 3초 이상 누르면 잠금 해제 상태가 유지되는 '잠금 비활성화 기능'이 있습니다. <br/>
초기 설계에서는 random_numbers, lock_10, display_pushed, door_state, alert, door_top 모듈이 제안되었으나, 여러 모듈 간 기능 중복 및 비효율적인 전력 소모(예: lock_10과 display_pushed의 비밀번호 입력 및 비교 기능 중복, door_state에 과도한 기능 집중, 전달 지연 방식을 사용한 alert 모듈) 문제점이 발견되었습니다. <br/>
특히 random_numbers 모듈은 10!의 많은 경우의 수를 처리하기 위해 회로가 너무 커질 수 있다는 한계가 있었습니다. <br/>
이러한 문제점을 개선하여 최종 버전에서는 button, random_numbers, display, compare, pw_reset, alert_counter, top_module의 모듈 구성으로 재설계되었습니다. <br/>

&nbsp;본 프로젝트에서 사용하는 버튼은 다음과 같습니다. <br/>
<p align="center"> 
  <img width="458" height="223" alt="image" src="https://github.com/user-attachments/assets/9db1e9e6-acf3-4bb3-a3bd-df22185cc683" />
</p>

## 스마트 도어락 모듈
### 1. button 모듈
&nbsp;실사용 환경에서 버튼 입력이 한 클록(clock) 동안만 신호로 인식되도록 설계되었습니다. <br/>
각 버튼 입력 (button[9:0], star, hash)에 대해 두 개의 레지스터(r1, r2 등)를 사용하여 입력의 라이징 엣지(rising edge)에서만 펄스(pulse) 출력을 생성함으로써 채터링(chattering) 방지 및 단일 클록 입력 처리를 구현합니다. <br/>
이는 Verilog의 비차단 할당(&lt;=)을 사용하여 현재 클록 사이클의 입력값을 이전 클록 사이클의 값과 비교함으로써 가능합니다. <br/>

### 2.random_numbers 모듈
&nbsp;지문 자국 방지 목표를 유지하면서 전력 소비를 줄이는 방향으로 개선되었습니다. <br/>
초기 버전의 10! 순열 대신, 미리 정의된 숫자 배열(1,3,7,9,2,0,8,5,6,4 순서)을 $urandom_range(0, 9)를 통해 생성된 랜덤 값만큼 순환 시프트(circular shift)시키는 방식을 채택했습니다. <br/>
입력 i_num (10비트 one-hot encoded)을 mid_num으로 정해진 순서로 재배열한 후, star 버튼이 눌릴 때마다 0부터 9 사이의 랜덤 정수 a를 생성하여 mid_num을 a만큼 좌측으로 순환 시프트하여 o_num으로 출력합니다. <br/>
순환 시프트 연산은 Verilog에서 다음과 같이 표현됩니다:
```verilog
assign o_num = (mid_num &lt;&lt; a) | (mid_num &gt;&gt; (10 - a));
```
이는 하드웨어 리소스를 효율적으로 사용하면서도 충분한 무작위성을 제공하여 지문 추적을 어렵게 합니다. <br/>

### 3. display 모듈
&nbsp;사용자가 입력한 숫자(버튼 button[9:0])를 10진수로 시퀀셜하게 저장하여 16비트 display 레지스터에 표시하고, 다음 모듈로 전달하는 역할을 합니다. <br/>
star(*) 또는 hash(#) 버튼이 눌리면 display 값을 16'd0으로 초기화합니다. 각 버튼 입력 시 display &lt;= display * 10 + digit; 연산을 통해 새로운 숫자를 기존 값의 뒤에 추가하는 방식으로 작동합니다. <br/>
이는 4자리 비밀번호를 10진수로 저장하기 위해 각 자리마다 4비트를 할당하여 총 16비트의 display 변수를 사용합니다. <br/>

### 4. compare 모듈
&nbsp;display 모듈로부터 받은 입력값과 저장된 비밀번호(pw), 임시 비밀번호(pw_temp)를 비교하고, 오류 횟수 (wrong)를 관리하며, 경보(alert) 신호를 발생시킵니다. <br/>
star 버튼이 눌렸을 때 display 값이 pw 또는 pw_temp와 일치하면 correct 신호를 1로 만들고 wrong 카운트를 0으로 초기화합니다. <br/>
pw_temp로 문이 열리면 pw_temp_reset 신호를 1로 설정하여 임시 비밀번호를 초기화하도록 합니다. <br/>
만약 display가 비밀번호와 일치하지 않으면 wrong 카운트를 증가시키고, wrong이 5에 도달하면 alert를 1로 설정하고 wrong을 0으로 초기화합니다. <br/>
alert_off 신호를 받아 알람을 끄고, close_sensor 신호에 따라 correct와 pw_temp_reset을 초기화합니다. <br/>

### 5. pw_reset 모듈
&nbsp;일반 비밀번호(pw)와 임시 비밀번호(pw_temp)를 재설정하는 기능을 유한 상태 머신(Finite State Machine, FSM)으로 구현합니다. <br/>

- INIT 상태: 초기 상태입니다. 문이 열린 상태(correct=1)에서 star 버튼이 눌리면 PW 상태로, hash 버튼이 눌리면 PW_TEMP 상태로 전이됩니다. <br/>
- PW 상태: 일반 비밀번호를 재설정하는 상태입니다. display에 입력된 숫자를 pw에 저장하고, star 버튼이 다시 눌리면 INIT 상태로 돌아갑니다. <br/>
- PW_TEMP 상태: 임시 비밀번호를 재설정하는 상태입니다. display에 입력된 숫자를 pw_temp에 저장하고, hash 버튼이 다시 눌리면 INIT 상태로 돌아갑니다. <br/>
리셋(reset) 신호가 들어오거나 pw_temp_reset 신호가 들어오면 pw 또는 pw_temp가 초기화됩니다. pw_temp는 16'bz (하이 임피던스)로 초기화되어 미사용 상태를 나타냅니다. <br/>

### 6. alert_counter 모듈
&nbsp;compare 모듈에서 발생한 enable 신호(경보 활성화)를 받아 일정 시간 동안 경보를 울리고 자동으로 끄는 기능을 카운터로 구현합니다. <br/>
enable이 1이면 내부 카운터(cnt)를 증가시키고 alert 신호를 1로 유지합니다. <br/>
cnt가 5에 도달하면 cnt를 0으로 초기화하고 alert를 0으로 변경하며 alert_off를 1로 설정하여 경보를 비활성화합니다. <br/>
이는 초기 버전의 전달 지연 방식 대신 클록 기반의 정밀한 시간 제어를 가능하게 하여 하드웨어 합성에 더 효율적입니다. <br/>
alert_off는 compare 모듈로 전달되어 알람을 끄는 데 사용됩니다. <br/>

## 모듈 테스트 및 분석
### 1. button 모듈
<img width="882" height="168" alt="image" src="https://github.com/user-attachments/assets/970dd0a4-36b1-4c1f-9646-e99ce72b9dc0" /> <br/>

<details>
  <summary>📋<strong>Testbench Code</strong></summary>
  
  ```verilog
  `timescale 10ms/10ms
  `include "button.v"
    
  module button_tb;
    reg [9:0] button;
    reg clk, star, hash;
    wire [9:0] o_button;
    wire o_star, o_hash;
      
    button i0(/*AUTOINST*/
      // Outputs
      .o_button (o_button[9:0]),
      .o_star (o_star),
      .o_hash (o_hash),
      // Inputs
      .clk (clk),
      .star (star),
      .hash (hash),
      .button (button[9:0]));
          
    always #50 clk <= ~clk;
        
    initial begin
      $dumpfile("button_tb.vcd");
      $dumpvars(0, button_tb);
      clk = 0;
      button = 0;
      star = 0;
      hash = 0;
      #100
      button[1] = 1;
      #100
      star = 1;
      #100
      hash = 1;
      #300
      button[1] = 0;
      #100
      star = 0;
      #100
      hash = 0;
      #500
      $finish;
    end // initial begin
  endmodule // button_tb
  ```
</details>

&nbsp;위의 tb 파형을 보면 button2 를 입력하면 그 다음 clock 에 o_button 이 출력됩니다. <br/>
그 다음 clock 때 버튼입력은 그대로인 반면에 o_button 은 출력이 종료된 것을 알 수 있습니다. <br/>
star 와 hash 역시 입력 후 다음 clock 때 출력하고 다음에 다시 0 이 됩니다. <br/>

### 2. random_numbers 모듈
<img width="882" height="168" alt="image" src="https://github.com/user-attachments/assets/f58edbb6-3935-40bf-9a98-7a49552dd88b" /> <br/>

<details>
  <summary>📋<strong>Testbench Code</strong></summary>
  
  ```verilog
  `timescale 10ns/10ns
  `include "random_numbers.v"

  module random_numbers_tb;
    reg star;
    reg [9:0] i_num;
    wire [9:0] o_num;
 
    random_numbers i0(/*AUTOINST*/
      // Outputs
      .o_num (o_num[9:0]),
      // Inputs
      .i_num (i_num[9:0]),
      .star (star));
    initial begin
      $dumpfile("random_numbers_tb.vcd");
      $dumpvars(0,random_numbers_tb);
      star = 0;
      i_num <= 10'd0;
      #10
      star = 1;
      i_num <= 10'b00_0000_0001;
      #10
      star = 0;
      i_num <= 10'd0;
      #10
      star=1;
      i_num <= 10'b00_0000_0100;
      #10
      star=0;
      i_num <= 10'd0;
      #10
      star=1;
      i_num <= 10'b01_0000_0000;
      #10
      star=0;
      i_num <= 10'd0;
      #10
      $finish;
    end // initial begin
  endmodule // random_numbers_tb
  ```
</details>

&nbsp;random_numbers 모듈을 테스트해보려 만든 tb 는 총 3 번의 pushed 가 되는 동안 숫자 배열을 추적하기 위해서 만들었습니다. <br/>
테스트해본 결과는 다음과 같습니다. <br/>
|**테스트**|**i_num**|**mid_num**|**a**|**o_num**|
|:---:|:---:|:---:|:---:|:---:|
|**1**|0|4|5|9|
|**2**|2|5|2|7|
|**3**|8|3|0|3|

&nbsp;i_num 입력으로 순서대로 0,2,8 에 1 을 넣어주어 값을 추적하려 하였습니다. <br/>
공통적으로 mid_num 은 i_num 의 배열을 1,3,7,9,2,0,8,5,6,4 순으로 가져가기에 테스트 순서대로 mid_num[4], mid_num[5],mid_num[3]에 1 이 출력되었습니다. <br/>
그 다음, pushed 가 눌리면 a 가 0~9 사이의 숫자로 랜덤하게 출력되는데 이번에는 5,2,0 순서로 값이 나왔습니다. <br/>
그 결과에 의해 mid_num 이 a 만큼 left-shift 되어 순서대로 o_num[9],o_num[7],o_num[3]에 1 이 출력되었습니다. <br/>
그리하여 테스트 1 은 디스플레이에 0,8,5,6,4,1,3,7,9,2 순으로 배열되고, 테스트 2 는 7,9,2,0,8,5,6,4,1,3 순으로, 테스트 3 은 1,3,7,9,2,0,8,5,6,4 순으로 배열되었다는 것을 알 수 있습니다. <br/>
이를 통하여 디스플레이의 숫자배열이 a 에 의해 랜덤하게 변화하여 지문자국을 활용한 침입을 방지할 수 있습니다. <br/>


