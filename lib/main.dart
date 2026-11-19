import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:module_abc/widgets/fade_in_object.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Typemain(),
  ));
}

// ───────── 기본 설정 ─────────

const fade = Duration(milliseconds: 350); // 나타나는 시간
const purple = Color(0xFFAA8ABF); // 선택 안 된 글자색

const textStyle = TextStyle(
  fontFamily: 'NanumMyeongjo',
  fontSize: 16,
  fontWeight: FontWeight.w800,
  color: Colors.white,
);

// 단계별 안내 문구 (번호 = currentStep)
const messages = [
  '운명을 엿볼 시간이에요.', // 0 시작
  '이름을 입력해주세요.', // 1
  '나이를 입력해주세요.', // 2
  '성별을 선택해주세요.', // 3
  '', // 4 생일 (문구 없음)
  '태어난 시간을 입력해주세요.', // 5
  '입력한 정보가 맞는지 확인해주세요.', // 6
];

// 구름 하나의 위치 정보
class Cloud {
  const Cloud({this.bottom, this.left, this.right, this.size = 250, this.rotation = 0, this.flip = false});
  final double? bottom, left, right;
  final double size, rotation;
  final bool flip;
}

const clouds = [
  Cloud(bottom: 20, right: -20),
  Cloud(bottom: 5, left: -50, rotation: 0.2),
  Cloud(bottom: -80, left: -40, size: 275, flip: true),
  Cloud(bottom: -20, right: -90),
  Cloud(bottom: -90, right: 5),
];

// ───────── 메인 화면 ─────────

class Typemain extends StatefulWidget {
  const Typemain({super.key});

  @override
  State<Typemain> createState() => _TypemainState();
}

class _TypemainState extends State<Typemain> {
  int currentStep = 0; // 지금 몇 번째 단계인지

  // 입력한 정보
  String name = '';
  int age = 0;
  bool? gender; // true = 남성, false = 여성
  DateTime? birthDate;
  String errorMessage = '';

  // 달력에 보여주는 달
  DateTime displayedMonth = DateTime.now();

  // 태어난 시간
  int hour = 9;
  int minute = 0;
  bool isAM = true;
  bool pickingHour = true; // true면 시 선택, false면 분 선택
  bool timeUnknown = false; // '잘 모르겠어요'를 눌렀는지

  // ───────── 공통으로 쓰는 작은 부품 ─────────

  // 반투명 둥근 버튼 (이전, 잘 모르겠어요)
  Widget pillButton(String text, IconData icon, VoidCallback onTap, {bool iconRight = false}) {
    final iconWidget = Icon(icon, color: Colors.white, size: 14);
    final textWidget = Text(text, style: const TextStyle(color: Colors.white, fontSize: 13));

    return Material(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: iconRight
                ? [textWidget, const SizedBox(width: 3), iconWidget] // 글자 → 아이콘
                : [iconWidget, const SizedBox(width: 3), textWidget], // 아이콘 → 글자
          ),
        ),
      ),
    );
  }

  // 입력창 테두리
  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  // ───────── 배경 (달, 구름) ─────────

  Widget buildMoon() {
    return FadeInObject(
      top: 0,
      left: 0,
      width: 150,
      height: 150,
      duration: fade,
      delay: Duration.zero,
      child: Image.asset('assets/images/moon.png'),
    );
  }

  List<Widget> buildClouds() {
    return List.generate(clouds.length, (i) {
      final c = clouds[i];
      Widget image = Image.asset('assets/images/cloud.png');
      if (c.flip) image = Transform.flip(flipX: true, child: image);

      return FadeInObject(
        bottom: c.bottom,
        left: c.left,
        right: c.right,
        width: c.size,
        height: c.size,
        rotation: c.rotation,
        duration: fade,
        delay: Duration(milliseconds: 350 + i * 70),
        child: image,
      );
    });
  }

  // ───────── 로고 + 안내 문구 ─────────

  Widget buildCenterContent(double screenWidth) {
    final first = currentStep == 0; // 첫 화면이면 더 아래에 배치

    return Stack(
      children: [
        FadeInObject(
          top: first ? 155 : 75,
          left: (screenWidth - 220) / 2,
          width: 220,
          height: 210,
          duration: fade,
          delay: const Duration(milliseconds: 980),
          child: Image.asset('assets/images/Daily Tarot.png'),
        ),
        FadeInObject(
          top: first ? 270 : 190,
          left: (screenWidth - 75) / 2,
          width: 75,
          height: 75,
          duration: fade,
          delay: const Duration(milliseconds: 980),
          child: Image.asset('assets/images/graphic.png'),
        ),
        FadeInObject(
          top: first ? 330 : 255,
          left: 0,
          right: 0,
          duration: fade,
          delay: const Duration(milliseconds: 980),
          child: Text(messages[currentStep], textAlign: TextAlign.center, style: textStyle),
        ),
      ],
    );
  }

  // ───────── 시작 버튼 ─────────

  // 보라색 그라데이션 버튼 모양 (첫 화면과 결과 화면에서 같이 사용)
  Widget gradientButton(String text, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF825B77), Color(0xFF3C1463), Color(0xFF3C1463)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB78AD6).withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text, style: textStyle.copyWith(letterSpacing: 0.3)),
              const SizedBox(width: 5),
              Transform.flip(
                flipX: true,
                child: SvgPicture.asset(
                  'assets/icons_A/arrow_back_ios_new_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 첫 화면의 시작하기 버튼
  Widget buildStartButton(double screenWidth) {
    return FadeInObject(
      top: 480,
      left: (screenWidth - 200) / 2,
      width: 200,
      height: 65,
      delay: const Duration(milliseconds: 1400),
      duration: fade,
      child: gradientButton('시작하기', () => setState(() => currentStep = 1)),
    );
  }

  // ───────── 아래쪽 버튼 (이전 / 잘 모르겠어요) ─────────

  Widget buildBottomButtons() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          pillButton('이전', Icons.chevron_left, () {
            setState(() {
              currentStep--;
              errorMessage = '';
              pickingHour = true;
            });
          }),
          // 시간 입력 단계에서만 보이는 버튼
          if (currentStep == 5) ...[
            const SizedBox(width: 10),
            pillButton('잘 모르겠어요', Icons.chevron_right, () {
              setState(() {
                timeUnknown = true; // 시간을 모른다고 기억
                currentStep = 6;
              });
            }, iconRight: true),
          ],
        ],
      ),
    );
  }

  // ───────── 진행률 막대 ─────────

  Widget buildProgressBar() {
    const total = 5;
    return Positioned(
      left: 10,
      right: 10,
      bottom: 0,
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 4,
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 3),
              decoration: BoxDecoration(
                color: currentStep > i ? Colors.white : Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ───────── 1~2단계: 이름, 나이 입력 ─────────

  Widget buildTextInput() {
    final isName = currentStep == 1;

    return Positioned(
      top: 330,
      left: 35,
      right: 35,
      child: TextField(
        textInputAction: TextInputAction.done,
        style: const TextStyle(color: Colors.white),
        keyboardType: isName ? TextInputType.text : TextInputType.number,
        // 이름은 한글/영문만, 나이는 숫자만
        inputFormatters: [
          isName
              ? FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z가-힣]'))
              : FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          hintText: messages[currentStep],
          hintStyle: const TextStyle(color: Colors.white70),
          enabledBorder: border(Colors.white54),
          focusedBorder: border(Colors.white),
          errorText: errorMessage.isEmpty ? null : errorMessage,
        ),
        onSubmitted: checkTextInput,
      ),
    );
  }

  // 입력값이 맞는지 검사하고 다음 단계로 넘어가기
  void checkTextInput(String value) {
    final input = value.trim();

    if (currentStep == 1) {
      if (input.length < 3 || input.length > 20) {
        setState(() => errorMessage = '이름은 3자 이상 20자 이하로 입력해주세요.');
        return;
      }
      setState(() {
        name = input;
        errorMessage = '';
        currentStep = 2;
      });
    } else {
      final inputAge = int.tryParse(input);
      if (inputAge == null || inputAge <= 0) {
        setState(() => errorMessage = '올바른 나이를 입력해주세요.');
        return;
      }
      setState(() {
        age = inputAge;
        errorMessage = '';
        currentStep = 3;
      });
    }
  }

  // ───────── 3단계: 성별 선택 ─────────

  Widget genderButton(bool isMale) {
    final selected = gender == isMale;
    final icon = isMale ? 'male' : 'female';

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = isMale;
          currentStep = 4;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(selected ? 1 : 0.75)),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/${icon}_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
            width: 50,
            height: 50,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget buildGenderSelection() {
    return Positioned(
      top: 370,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          genderButton(false),
          const SizedBox(width: 20),
          genderButton(true),
        ],
      ),
    );
  }

  // ───────── 4단계: 생년월일 달력 ─────────

  // 연도와 월을 고르는 팝업
  Future<void> showYearMonthDialog() async {
    final now = DateTime.now();
    int year = displayedMonth.year;
    int month = displayedMonth.month;

    final yearCtrl = FixedExtentScrollController(initialItem: year - 1900);
    final monthCtrl = FixedExtentScrollController(initialItem: month - 1);

    // 돌려서 고르는 선택기 (연도용, 월용 둘 다 모양이 같아서 함수로 만듦)
    Widget picker(FixedExtentScrollController ctrl, int count, String Function(int) label, ValueChanged<int> onChanged) {
      return CupertinoPicker(
        itemExtent: 40,
        scrollController: ctrl,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: Color(0x33FFFFFF)),
        onSelectedItemChanged: onChanged,
        children: List.generate(
          count,
              (i) => Center(child: Text(label(i), style: textStyle.copyWith(fontSize: 17))),
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF32104F),
          title: Text('연도와 월 선택', style: textStyle.copyWith(fontSize: 18)),
          content: SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: picker(yearCtrl, now.year - 1900 + 1, (i) => '${1900 + i}년', (i) {
                    year = 1900 + i;
                    // 올해라면 미래의 월은 못 고르게 막기
                    if (year == now.year && month > now.month) {
                      month = now.month;
                      monthCtrl.jumpToItem(month - 1);
                    }
                  }),
                ),
                Expanded(
                  child: picker(monthCtrl, 12, (i) => '${i + 1}월', (i) => month = i + 1),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                setState(() => displayedMonth = DateTime(year, month));
                Navigator.pop(dialogContext);
              },
              child: const Text('완료', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    yearCtrl.dispose();
    monthCtrl.dispose();
  }

  Widget buildBirthDatePicker() {
    final year = displayedMonth.year;
    final month = displayedMonth.month;

    final startDay = DateTime(year, month, 1).weekday % 7; // 1일의 요일 (일요일 = 0)
    final lastDay = DateTime(year, month + 1, 0).day; // 이번 달 마지막 날짜
    final totalCells = ((startDay + lastDay + 6) ~/ 7) * 7; // 달력 칸 수

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Positioned(
      top: 330,
      left: 25,
      right: 25,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 연도.월 (누르면 선택 팝업)
          SizedBox(
            height: 45,
            child: Center(
              child: GestureDetector(
                onTap: showYearMonthDialog,
                child: Text('$year.$month', style: textStyle.copyWith(fontSize: 23, fontWeight: FontWeight.w700)),
              ),
            ),
          ),

          // 요일
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토'].map((d) {
              return Expanded(
                child: Center(
                  child: Text(d, style: textStyle.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.65))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 5),

          // 날짜
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemBuilder: (context, index) {
              final day = index - startDay + 1;
              if (day < 1 || day > lastDay) return const SizedBox(); // 빈 칸

              final date = DateTime(year, month, day);
              final isSelected = birthDate == date;
              final isFuture = date.isAfter(today);

              return GestureDetector(
                onTap: isFuture
                    ? null
                    : () => setState(() {
                  birthDate = date;
                  pickingHour = true;
                  currentStep = 5;
                }),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$day',
                    style: textStyle.copyWith(
                      color: isFuture ? Colors.white.withOpacity(0.25) : Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ───────── 5단계: 태어난 시간 (시계) ─────────

  // "09" 같은 숫자 상자 (선택되면 테두리가 생김)
  Widget timeBox(int value, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: selected ? Border.all(color: purple, width: 1.5) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            color: selected ? Colors.white : purple,
            fontSize: 30,
            fontFamily: 'NanumMyeongjo',
          ),
        ),
      ),
    );
  }

  // AM 또는 PM 글자 하나
  Widget ampmText(String text, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isAM = text == 'AM'),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : purple,
              fontSize: 15,
              fontFamily: 'NanumMyeongjo',
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBirthTimePicker() {
    const clockSize = 190.0;
    const numberRadius = 70.0;

    return Positioned(
      top: 330,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // 위쪽: 시 : 분  AM/PM
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              timeBox(hour, pickingHour, () => setState(() => pickingHour = true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(':', style: TextStyle(color: Colors.white, fontSize: 30)),
              ),
              timeBox(minute, !pickingHour, () => setState(() => pickingHour = false)),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ampmText('AM', isAM),
                    Container(height: 1.5, color: Colors.white),
                    ampmText('PM', !isAM),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 시계
          SizedBox(
            width: clockSize,
            height: clockSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 시계 테두리
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70),
                  ),
                ),

                // 숫자 12개를 원 모양으로 배치 (cos, sin 사용)
                ...List.generate(12, (i) {
                  final angle = -pi / 2 + i * pi / 6;
                  final number = pickingHour ? (i == 0 ? 12 : i) : i * 5;
                  final selected = pickingHour ? hour == number : minute == number;

                  return Positioned(
                    left: clockSize / 2 + cos(angle) * numberRadius - 13,
                    top: clockSize / 2 + sin(angle) * numberRadius - 13,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (pickingHour) {
                            hour = number;
                            pickingHour = false; // 시를 고르면 분 선택으로
                          } else {
                            minute = number;
                            timeUnknown = false;
                            currentStep = 6; // 분까지 고르면 확인 화면으로
                          }
                        });
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? Colors.white : Colors.transparent),
                        ),
                        child: Text(
                          number.toString().padLeft(2, '0'),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'NanumMyeongjo'),
                        ),
                      ),
                    ),
                  );
                }),

                // 시곗바늘 (선택한 숫자 방향으로 회전)
                Transform.rotate(
                  angle: -pi / 2 + (pickingHour ? hour % 12 : minute ~/ 5) * pi / 6,
                  child: SizedBox(
                    width: 114,
                    height: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(width: 57, height: 1, color: Colors.white),
                    ),
                  ),
                ),
                const CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── 6단계: 결과(확인) 화면 ─────────

  // 생년월일 글자 (예: 2026.04.01)
  String get birthText {
    final d = birthDate;
    if (d == null) return '-';
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  // 태어난 시간 글자 (24시간 방식, 예: 21:00)
  String get timeText {
    if (timeUnknown) return '모름';
    final hour24 = hour % 12 + (isAM ? 0 : 12); // PM이면 12를 더함
    return '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  // 정보 한 줄 (둥근 테두리 상자)
  Widget infoBox(String text) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text, style: textStyle.copyWith(fontSize: 14)),
    );
  }

  // 성별을 보여주는 동그라미
  Widget genderCircle() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 1.5),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/${gender == true ? 'male' : 'female'}_24dp_E3E3E3_FILL0_wght100_GRAD0_opsz24.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget buildResultScreen() {
    return Stack(
      children: [
        // 입력한 정보 4줄
        Positioned(
          top: 330,
          left: 35,
          right: 35,
          child: Column(
            children: [
              infoBox('이름 : $name'),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: infoBox('나이 : ${age}세')),
                  if (gender != null) ...[
                    const SizedBox(width: 10),
                    genderCircle(),
                  ],
                ],
              ),
              const SizedBox(height: 15),
              infoBox('생일 : $birthText'),
              const SizedBox(height: 15),
              infoBox('태어난 시간 : $timeText'),
            ],
          ),
        ),

        // 아래쪽 시작하기 버튼
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 200,
              height: 65,
              child: gradientButton('시작하기', () {
                // TODO: 다음 화면(타로 결과)으로 이동하는 코드를 여기에 넣기
                debugPrint('$name / $age / $gender / $birthText / $timeText');
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ───────── 단계마다 화면 바꾸기 ─────────

  Widget buildCurrentForm() {
    switch (currentStep) {
      case 1:
      case 2:
        return buildTextInput();
      case 3:
        return buildGenderSelection();
      case 4:
        return buildBirthDatePicker();
      case 5:
        return buildBirthTimePicker();
      case 6:
        return buildResultScreen();
      default:
        return const SizedBox(); // 0단계는 아무것도 없음
    }
  }

  Widget buildFormPageTransition() {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: fade,
        // 바뀔 때 서서히 나타나면서 살짝 커지는 효과
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: Stack(
          key: ValueKey(currentStep), // 단계가 바뀌면 새 화면으로 인식
          fit: StackFit.expand,
          children: [buildCurrentForm()],
        ),
      ),
    );
  }

  // ───────── 전체 화면 ─────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3C1363), Color(0xFF270C40)],
          ),
        ),
        child: Stack(
          children: [
            buildMoon(),
            ...buildClouds(),
            buildCenterContent(screenWidth),
            if (currentStep == 0) buildStartButton(screenWidth),
            buildFormPageTransition(),
            if (currentStep > 0 && currentStep < 6) buildBottomButtons(),
            buildProgressBar(),
          ],
        ),
      ),
    );
  }
}
