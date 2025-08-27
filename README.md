<p align="center">
  <h1 align="center">특수기능을 포함한 스마트 도어락 설계✨</h1>
  <img width="100%" alt="Simulation_Full_Screen" src="https://github.com/user-attachments/assets/1e176748-8a40-4256-83f3-a1216642ce5a" />
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
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/970dd0a4-36b1-4c1f-9646-e99ce72b9dc0" /> <br/>

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
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/f58edbb6-3935-40bf-9a98-7a49552dd88b" /> <br/>

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

### 3. display 모듈
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/03863160-0138-4c77-bc28-739d8aedc016" /> <br/>

<details>
  <summary>📋<strong>Testbench Code</strong></summary>
  
  ```verilog
  `include "new_display.v"
  `timescale 10ms/10ms
  
  module new_display_tb;
    reg[9:0] button;
    reg clk;
    reg star, hash;
    wire [15:0] display;
    wire [9:0] temp_button;

    new_display i0(
      .button(button[9:0]),
      .clk(clk),
      .star(star),
      .hash(hash),
      .display(display[15:0]));

    always #25 clk <= ~clk;

    initial begin
      $dumpfile("new_display_tb.vcd");
      $dumpvars(0, new_display_tb);

      clk = 0;
      hash = 0;
      button = 0;
      star = 0;

      #50 star = 0;
      #50 star = 1;
      #50 star = 0;
      #50 button[5] = 1;
      #50 button[5] = 0;

      button[2] = 1;
      #50 button[2] = 0;

      button[5] = 1;
      #50 button[5] = 0;

      button[6] = 1;
      #50 button[6] = 0;

      #50 star = 1;
      #50 star = 0;
      #50;
      $finish;
    end // initial begin
  endmodule // new_display_tb
  ```
</details>

&nbsp;display 모듈을 test 해본 결과는 위와 같습니다. <br/>
초기에 star 를 눌러 display 를 16’b0 으로 reset 하고 clk 의 한 주기 동안 5, 2, 5, 6 에 해당하는 button[9:0]을 1 로 만들어 입력시켰습니다. <br/>
hash 또한 reset 할 수 있음을 확인하기 위해서 모든 입력 뒤에 hash 를 1 로 만들어 reset 시켰습니다. <br/>
display 파형을 보면 button 이 입력이 들어올 때마다 display 에 누적되며 값이 나타나는 것을 알 수 있습니다. <br/>
display 모듈에서는 pw 와 일치하는지 등의 기능을 일체 수행하지 않기 때문에 더 이상의 파형 변화는 생기지 않는 것 또한 확인할 수 있습니다. <br/>

### 4. compare 모듈
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/455e4bbc-44c4-4b11-9b00-3156eecbbcab" /> <br/>

<details>
  <summary>📋<strong>Testbench Code</strong></summary>
  
  ```verilog
  `timescale 10ms/10ms
  `include "compare.v"

  module compare_tb;
    reg star, alert_off, close_sensor;
    reg clk;
    reg [15:0] pw, pw_temp, display;
    wire correct, alert, pw_temp_reset, unlock;
 
    compare i0(/*AUTOINST*/
      // Outputs
      .correct (correct),
      .alert (alert),
      .pw_temp_reset (pw_temp_reset),
      .unlock (unlock),
      // Inputs
      .star (star),
      .clk (clk),
      .alert_off (alert_off),
      .close_sensor (close_sensor),
      .pw (pw[15:0]),
      .pw_temp (pw_temp[15:0]),
      .display (display[15:0]));

      always #50 clk = ~clk;
 
      initial begin
        $dumpfile("compare_tb.vcd");
        $dumpvars(0, compare_tb);
        pw = 16'd3589;
        pw_temp = 16'd1234;
        clk = 0;
        display = 16'd0000;
        star = 0;
        alert_off = 0;
        close_sensor = 0;
        #100 star = 1; //wrong
        #100 star = 0;
        display = 16'd3589;
        #100 star = 1; // pw correct
        #100 star = 0;
        close_sensor = 1;  
        #100 close_sensor = 0;
        display = 16'd1234;
        #100 star = 1; // pw_temp correct
        #100 star = 0;
        close_sensor = 1;
        #100 close_sensor = 0;
        display = 16'd5555;
        #100 star = 1; //wrong = 1
        #100 star = 0;
        display = 16'd5555;
        #100 star = 1; //wrong = 2
        #100 star = 0;
        display = 16'd5555;
        #100 star = 1; //wrong = 3
        #100 star = 0;
        display = 16'd5555;
        #100 star = 1; //wrong = 4
        #100 star = 0;
        display = 16'd5555;
        #100 star = 1; //wrong = 5 (alarm on)
        #100 star = 0;
        alert_off = 1;
        #500
        $finish;
     end // initial begin
  endmodule // compare_tb
  ```
</details>

&nbsp;pw = 3589, pw_temp = 1234 로 설정했습니다. <br/>
처음 star 입력에서는 아직 display 가 0 이므로 잠금이 풀리지 않았습니다. <br/>
다음 star 입력에서 display 와 pw 가 동일하여 잠금이 풀리고 close_sensor 에 의해 다시 잠긴 모습입니다. <br/>
다음 star 에서는 임시비밀번호와 동일하여 잠금이 풀렸고 곧바로 pw_temp_reset 이 활성화 되었습니다. <br/>
compare module 에서는 아직 재설정 모듈과 연계되지 않아 임시비밀번호가 초기화 되진 않았습니다. <br/>
마지막은 비밀번호 5 회 오류로 인해 alert 가 활성화 되고 alert_off 에 의해 다시 0 으로 바뀌었습니다. <br/>

### 5. pw_reset 모듈
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/42a15820-2aca-4237-acf4-0a043290422b" /> <br/>

<details>
  <summary>📋<strong>Testbench Code</strong></summary>
  
  ```verilog
  `include "pw_reset.v"
  `timescale 10ms/10ms

  module pw_reset_tb;
    reg clk, correct, pw_temp_reset, hash, star, reset;
    reg [15:0] display;
    wire [15:0] pw, pw_temp;

    pw_reset i0(.clk(clk), .correct(correct), .pw_temp_reset(pw_temp_reset), .hash(hash), .star(star), .reset(reset), .display(display[15:0]), .pw(pw), .pw_temp(pw_temp));
 
    always #50 clk = ~clk;

    initial begin
      $dumpfile("pw_reset_tb.vcd");
      $dumpvars(0, pw_reset_tb);
      clk = 0;
      correct = 1;
      display[15:0] = 16'b0;
      hash = 0;
      star = 0;
      pw_temp_reset = 0;
      reset = 1;
      #75 reset = 0;
      #50 star = 1;
      #50 star = 0;
      #50 display = 16'b0001001000110100;
      #100 star = 1;
      #50 display = 0;
      #0 star = 0;

      #50 hash = 1;
      #50 hash = 0;
      #50 display = 16'b1001100001110110;
      #100 hash = 1;
      #50 display = 0;
      #0 hash = 0;

      #150 pw_temp_reset = 1;
      #50 pw_temp_reset = 0;
      #100
      $finish;
    end // initial begin
  endmodule // pw_reset_tb
  ```
</details>

&nbsp;pw_reset 을 test bench 해본 결과입니다. <br/>
먼저 reset 을 1 로 하여 일반 비밀번호(pw)를 0 으로, 임시 비밀번호(pw_temp)를 하이 임피던스(16’bz)로 초기화합니다. <br/>
그리고 pw 및 pw_temp 를 재설정할 때는 문이 열려있어야 하므로 correct 를 항상 1 로 두었습니다. <br/>
pw 를 재설정하기 위해 star(*) 버튼을 누르고 다음 clk에서 display 값이 1234 이므로 pw에 1234로 저장된 것을 볼 수 있습니다. <br/>
버튼을 눌러 초기(INIT) 상태로 돌아갑니다. <br/>
그 다음 pw_temp 를 재설정하기 위해 hash(#) 버튼을 누르고 다음 clk 에서 display 값이 9876 이므로 pw_temp에 9876 이 저장된 것을 볼 수 있습니다. <br/>
마찬가지로 hash(#) 버튼을 다시 눌러 초기(INIT) 상태로 돌아갑니다. <br/>
그 뒤 임시 비밀번호로 문을 열었을 때를 가정하여 pw_temp_reset 을 1 로 두었을 때 pw_temp 가 다시 하이 임피던스로 초기화되는 것을 볼 수 있습니다. <br/>

### 6. alert_counter 모듈
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/0566d6e1-9a57-4e78-bddc-38bc6aa1ff4c" /> <br/>

<details>
  <summary>📋<strong>Testbench Code</strong></summary>
  
  ```verilog
  `timescale 10ms/10ms
  `include "alert_counter.v"

  module alert_counter_tb;
    reg enable, clk;
    wire alert, alert_off;

    alert_counter i0(
      .enable(enable),
      .clk(clk),
      .alert(alert),
      .alert_off(alert_off));

    always #25 clk = ~clk;

    initial begin
    $dumpfile("alert_counter_tb.vcd");
    $dumpvars(0, alert_counter_tb);
    enable = 0;
    clk = 0;
    #100
    enable = 1;
    #600
    enable = 0;
    $finish;
    end
  endmodule // alert_counter_tb
  ```
</details>

&nbsp;alert_counter 모듈을 test bench 해본 결과입니다. <br/>
enable 값이 인가 되고 cnt 에 의해 alert 을 알려주면서, clock 간에 카운트가 들어갑니다. <br/>
cnt 가 5 가되면, alert 는 0 이 되고, 동시에 alert_off 를 1 로 신호를 줍니다. <br/>
이는 compare 모듈의 alert 와 연계되어 사용됩니다. <br/>

### 7. top_module 모듈
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/18ab5bb4-744f-480a-9e7b-1da59e18bc20" />
<동적 키패드 배열 소개 및 초기 비밀번호 0000> <br/>

&nbsp;비빌먼호 초기값이 000 으로 설정 되어있어 비밀번호를 바꾸기 위한 과정입니다. <br/>
button[9:0]은 0 번째 부터 9 번째까지 디스플레이 0 ~ 9 에 해당합니다. <br/>
즉, 버튼의 0 번째는 0 을 의미하는 것입니다. <br/>
0000000001 의 파형은 0 을 눌렀다는 뜻입니다. <br/>
밑의 random_button[9:0] 배열은 button[9:0]에 대응되는 숫자의 위치를 나타냅니다. <br/>
button[9:0]에서 숫자 0 이 9 번째 순서로 이동 됩니다. <br/>
원래는 9 가 위치해야 할 곳에 0 이 위치한 것이고, 사용자는 이 위치에서 숫자 0 을 입력한 것입니다. <br/>
따라서, display 에 0000 이 출력되는 것을 볼 수 있습니다. <br/>

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/f929cbd0-4d12-49c4-b24f-6a7804f3c7af" />
<문열림 상태에서 비밀번호 재설정> <br/>

&nbsp;문열림 상태에서 *(star)버튼을 누르면 비밀번호를 재설정 할 수 있습니다. <br/>
이상태에서 button[9:0] 의 숫자 9, 8, 7, 6을 입력하여 비밀번호를 9876으로 재설정 합니다. <br/>
재설정할때에도, 해당숫자의 위치는 바뀝니다. <br/>

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/f53b087c-8a62-498e-9988-54a7409426f3" />
<close_sensor(걸쇠)의 역할> <br/>

&nbsp;close_sensor(걸쇠)의 역할은 비밀번호 입력 후, 문이 열리고 닫힐 때의 걸쇠 역할을 해줍니다. <br/>
1 의 신호를 줬다는 의미는, 문이 걸쇠에 걸리고 닫힘 상태에 들어간다는 것 입니다. <br/>
이후, unlock 이 0 으로 되어 문이 닫혔다는 것을 알려줍니다. <br/>

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/fea6cb13-fc8e-41a6-9d2c-664eded73bb6" />
<비밀번호 9876으로 변경 후 도어락의 동작> <br/>

&nbsp;9876으로 비밀번호를 변경한 뒤, 도어락이 정상 작동하는 것을 알 수 있습니다. <br/>

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/989685f5-e693-4d01-a695-7bacba3a02b9" />
<임시 비밀번호(pw_temp)의 재설정> <br/>

&nbsp;문이 열린 상태에서, #(hash)버튼을 누르면 임시 비밀번호를 재설정하는 상태로 들어갑니다. <br/>
이때에도, 숫자의 물리적 위치는 바뀌며, display 도 출력되는 것을 알 수 있습니다. <br/>
밑의 pw_temp[15:0]의 파형은 display[15:0]의 값을 받아와 설정하는 것을 알 수 있습니다. <br/>

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/360f5c40-1187-48b4-8666-83bcfa4ceb6b" />
<임시 비밀번호(pw_temp)의 사용> <br/>

&nbsp;임시 비밀번호(pw_temp)의 설정 이후, 임시 비밀번호를 사용하여 문을 여는 상황입니다. <br/>
임시 비밀번호(pw_temp)를 입력하고, *(star)를 입력할 시, pw_temp[15:0]에 저장되 있던 값은 바로 z(하이 임피던스)값으로 초기화 되는 것을 볼 수 있습니다. <br/>
이는 한 번 입력하고 문을 열시에 바로 삭제된다는 것을 알 수 있습니다. <br/>

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/ed68c2ef-7111-4bce-b594-db6a98d0a12f" />
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/b3a06f7a-03c3-4e56-95c2-e72836e0fc03" />
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/b5b2d986-6484-4c9c-844d-d72d187a473f" />
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/1db163b6-d977-4e23-90f9-bf613eb02a83" />
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/4b8cb50b-82d4-4147-8203-f17f5b3fda22" />
<img width="100%" alt="image" src="https://github.com/user-attachments/assets/4840a846-66b8-4c50-8e7b-7130341c94c7" />
<alert의 기능(alert가 울린 뒤, 5 clock cycle 뒤에 종료)> <br/>

&nbsp;임시 비밀번호 1111은 사용되었으므로, 더 이상 문을 open 시키는 데에는 유효한비밀번호가 아닙니다. <br/>
이 비밀번호 1111을 5 번 입력하게 되면, wrong 이 점점 증가 하게 되는데, 5번이 되었을 시, alert가 울립니다. <br/>
이 alert는 계속 울리면 안되므로, 초기화가 필요합니다. <br/>
alert가 울리고 클락의 주기를 alert_counter 가 카운터를 하며, cnt[2:0]가 5가 되었을 시에 초기화를 하여 alert를 꺼줍니다. <br/>

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/50b17723-4ab9-4ae2-b696-b33198283f67" />
<잠금 비활성화 장치(걸쇠에 걸려도 문이 항상 open)> <br/>

&nbsp;비밀번호를 입력하여 문을 열고, open_button을 3초이상 누를 시, always_open의 값이 1로 바뀝니다. <br/>
이 상태에서는 문을 닫아도(close_sensor 의 입력을 주어도) 문은 항상 open 됩니다. <br/>
만약, open_button의 버튼을 처음 1초 동안 눌렀다가 몇초 뒤에 다시 누른다고 하면, 처음 버튼을 누르면 always_open_ctrl[2:0]의 값이 증가하지만, 그 다음의 클락의 open_button 입력이 이루어지지 않았으므로, always_open_ctrl[2:0]의 값과 prev_always_open[2:0]의 값이 같아지며, always_open_ctrl[2:0]의 값의 초기화가 이루어집니다. <br/>
이로 인해 버튼을 3 초 이상 누르지 않으면, always_open 모드가 되지 않는 것을 알 수 있습니다. <br/>
잠금 비활성화 모드를 종료하는 것도 마찬가지입니다. <br/>
잠금 비활성화 모드가 작동된 상황에서, open_button을 3초이상 누르면, 종료됩니다. <Br/>
always_open_ctrl[2:0]이 6 초과가 되기만 하면, always_open의 값이 반대가 되기 때문에 종료가 되는 원리입니다. <br/>

## 결론
<p align="center"> 
  <img width="837" height="580" alt="image" src="https://github.com/user-attachments/assets/9484a3d6-e3cd-4b9b-b2a7-46a7d26a530c" />
</p>

&nbsp;프로젝트를 수행한 결과, 초기에 목표로 하였던 동적 키패드 디스플레이 기능 및 임시 비밀번호 기능, 경보 기능과 잠금 비활성화 기능을 포함한 디지털 도어락을 설계할 수 있었습니다. <br/>

&nbsp;동적 키패드 디스플레이의 경우, 비밀번호를 새로 입력하기 위해 초기화를 할 때마다 키패드가 무작위로 배치되도록 구현하였습니다. <br/>
이러한 기능을 통해 비밀번호 자체를 지속적으로 변경하지 않고도 지문 자국으로 비밀번호를 유추하는 것을 방지할 수 있습니다. <br/>
비밀번호를 알아내어 무단침입하는 경우의 가장 빈번한 원인이 지문 자국이므로 이러한 동적 키패드 디스플레이를 통해 높은 보안 수준을 유지할 수 있습니다. <br/>

&nbsp;또한, 임시 비밀번호를 생성하여 해당 비밀번호로 문을 한 번 열면 만료되는 일회성 비밀번호를 구현하였습니다. <br/>
실생활에서 타인에게 비밀번호를 일회성을 알려주기 위해 기존의 익숙한 비밀번호를 재설정할 필요가 없어 편리성을 높였습니다. <br/>
 
&nbsp;비밀번호 입력시 연속 5회 이상 잘못 입력하면 외부인이 무단침입을 시도하는 것으로 판단하여 경보 알람을 울리도록 하였습니다. <br/>
경보 기능을 통해 동적 키패드 디스플레이와 함께 이중으로 보안을 유지하기 위해 노력하였습니다. <br/>

&nbsp;마지막으로 잠금 비활성화 기능을 통해 3초 이상 open버튼을 누르면 문의 여닫힘과 상관없이 항상 잠금을 해제할 수 있도록 하였습니다. <br/>
다시 한 번 3초 이상 open버튼을 누르면 일반적인 도어락 상태로 돌아갑니다. <br/>
이 기능을 통해 이사나 청소 등 외부인이 드나들어야 할 상황에서 편리함을 얻을 수 있을 것으로 기대됩니다. <br/>

&nbsp;특수 기능 외에도 일반적인 디지털 도어락 기능의 경우, 10진수 최대 4자리 비밀번호를 입력받아 설정해둔 비밀번호와 일치하면 문이 열리고 불일치하면 문이 열리지 않도록 하였습니다. <br/>
또한, 문이 열린 상태에서 *(star) 버튼을 통해 비밀번호를 재설정할 수 있습니다. <br/>
특수 기능 중 하나인 임시 비밀번호도 문이 열린 상태에서 #(hash) 버튼을 눌러 재설정할 수 있습니다. <br/>

&nbsp;앞서 말한 기능들을 모두 수행함과 동시에 저전력으로 동작할 수 있도록 하였습니다. <br/>
회로가 저전력으로 동작하기 위해서는 불필요한 회로 없이 효율적인 설계가 되어야 한다고 판단하였습니다. <br/>
따라서 초기버전과 같이 설계한 내용에서 중복되는 기능 및 코드를 발견하고 전체적으로 코드를 재설계하여 효율성을 높일 수 있었습니다. <br/>
중복되는 부분이 없는 효율적인 코드는 추후에 회로를 합성하였을 때도 회로의 면적이 작아 더 빠르게 동작하고 불필요한 전력 소모를 줄일 수 있을 것으로 기대됩니다. <br/> 
