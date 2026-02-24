import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/business_profile.dart';
import '../models/generated_documents.dart';
import '../theme/app_theme.dart';
import '../utils/sanitizer.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

  final _companyNameCtrl = TextEditingController();
  final _brandNameCtrl = TextEditingController();
  final _mainProductsCtrl = TextEditingController();
  final _targetCustomerCtrl = TextEditingController();
  String _industryType = '';
  bool _presetApplied = false;

  int _agentCount = 1;
  int _monthlyBudget = 500000;
  int _dailyCalls = 50;
  final _storeAddressCtrl = TextEditingController();
  final _storeHoursCtrl = TextEditingController();
  final _parkingInfoCtrl = TextEditingController();

  bool _usePhone = true, _useChannelTalk = true, _useEmail = false, _useSns = true, _useBoard = true;
  final _phoneNumberCtrl = TextEditingController();
  final _phoneHoursCtrl = TextEditingController(text: '09:00~18:00');
  final _channelTalkIdCtrl = TextEditingController();
  final _channelTalkHoursCtrl = TextEditingController(text: '09:00~18:00');
  bool _alfEnabled = true;
  final _supportEmailCtrl = TextEditingController();
  int _emailResponseTarget = 24;
  bool _useKakao = true, _useNaver = false, _useInstaDm = false;
  final _snsHoursCtrl = TextEditingController(text: '09:00~18:00');

  List<AgentRole> _agentRoles = [];

  final _salesChannelsCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _kakaoCtrl = TextEditingController();
  final _instaCtrl = TextEditingController();
  final _specialNotesCtrl = TextEditingController();

  final _industries = ['자동차/튜닝', '음식/외식', '뷰티/미용', 'IT/전자', '패션/의류', '건강/의료', '교육/학습', '인테리어/가구', '반려동물', '스포츠/레저', '기타 소매업', '기타 서비스업'];
  final _industryKeys = ['자동차/튜닝', '음식/외식', '뷰티/미용', 'IT/전자', '패션/의류', '건강/의료', '교육/학습', '인테리어/가구', '반려동물', '스포츠/레저', '기타 소매업', '기타 서비스업'];
  final _industryIcons = [Icons.directions_car, Icons.restaurant, Icons.spa, Icons.computer, Icons.checkroom, Icons.medical_services, Icons.school, Icons.chair, Icons.pets, Icons.sports_tennis, Icons.store, Icons.miscellaneous_services];

  @override
  void initState() { super.initState(); _generateRoles(); }

  @override
  void dispose() {
    _pageController.dispose(); _companyNameCtrl.dispose(); _brandNameCtrl.dispose();
    _mainProductsCtrl.dispose(); _targetCustomerCtrl.dispose(); _storeAddressCtrl.dispose();
    _storeHoursCtrl.dispose(); _parkingInfoCtrl.dispose(); _phoneNumberCtrl.dispose();
    _phoneHoursCtrl.dispose(); _channelTalkIdCtrl.dispose(); _channelTalkHoursCtrl.dispose();
    _supportEmailCtrl.dispose(); _snsHoursCtrl.dispose(); _salesChannelsCtrl.dispose();
    _websiteCtrl.dispose(); _kakaoCtrl.dispose(); _instaCtrl.dispose(); _specialNotesCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(String industry) {
    final preset = IndustryPreset.presets[industry];
    if (preset == null) return;
    setState(() {
      _usePhone = preset.phone; _useChannelTalk = preset.channelTalk;
      _useEmail = preset.email; _useSns = preset.sns; _useBoard = preset.board;
      _useKakao = preset.kakao; _useNaver = preset.naver; _useInstaDm = preset.instaDm;
      _agentCount = preset.recommendedAgents; _monthlyBudget = preset.recommendedBudget;
      _dailyCalls = preset.estimatedDailyCalls; _presetApplied = true;
    });
  }

  void _generateRoles() {
    final tp = BusinessProfile(agentCount: _agentCount, usePhoneChannel: _usePhone, useChannelTalk: _useChannelTalk,
      useEmailChannel: _useEmail, useSnsChannel: _useSns, useBoardChannel: _useBoard);
    setState(() { _agentRoles = tp.generateDefaultRoles(); });
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep == 0 && _industryType.isEmpty) return;
      if (_currentStep < 3) {
        if (_currentStep == 1) _generateRoles();
        setState(() => _currentStep++);
        _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      } else {
        _submit();
      }
    }
  }

  void _quickStart() {
    if (_companyNameCtrl.text.isEmpty || _brandNameCtrl.text.isEmpty || _industryType.isEmpty || _mainProductsCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('필수 항목을 입력해주세요'), behavior: SnackBarBehavior.floating));
      return;
    }
    _applyPreset(_industryType);
    _generateRoles();
    _submit();
  }

  void _prevStep() {
    if (_currentStep > 0) { setState(() => _currentStep--); _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut); }
  }

  void _submit() {
    final provider = context.read<AppProvider>();
    provider.updateProfile(BusinessProfile(
      companyName: InputSanitizer.sanitize(_companyNameCtrl.text),
      brandName: InputSanitizer.sanitize(_brandNameCtrl.text),
      industryType: _industryType,
      targetCustomer: InputSanitizer.sanitize(_targetCustomerCtrl.text),
      mainProducts: InputSanitizer.sanitize(_mainProductsCtrl.text),
      salesChannels: InputSanitizer.sanitize(_salesChannelsCtrl.text),
      agentCount: _agentCount,
      monthlyBudget: _monthlyBudget,
      dailyCalls: _dailyCalls,
      storeAddress: InputSanitizer.sanitize(_storeAddressCtrl.text),
      storeHours: InputSanitizer.sanitize(_storeHoursCtrl.text),
      parkingInfo: InputSanitizer.sanitize(_parkingInfoCtrl.text),
      websiteUrl: InputSanitizer.sanitizeUrl(_websiteCtrl.text),
      kakaoChannel: InputSanitizer.sanitize(_kakaoCtrl.text),
      instagramId: InputSanitizer.sanitize(_instaCtrl.text),
      specialNotes: InputSanitizer.sanitize(_specialNotesCtrl.text),
      usePhoneChannel: _usePhone,
      useChannelTalk: _useChannelTalk,
      useEmailChannel: _useEmail,
      useSnsChannel: _useSns,
      useBoardChannel: _useBoard,
      phoneNumber: InputSanitizer.sanitizePhone(_phoneNumberCtrl.text),
      phoneOperatingHours: InputSanitizer.sanitize(_phoneHoursCtrl.text),
      channelTalkId: InputSanitizer.sanitize(_channelTalkIdCtrl.text),
      channelTalkOperatingHours: InputSanitizer.sanitize(_channelTalkHoursCtrl.text),
      channelTalkAlfEnabled: _alfEnabled,
      supportEmail: InputSanitizer.sanitize(_supportEmailCtrl.text),
      emailResponseTarget: _emailResponseTarget,
      useKakaoConsult: _useKakao,
      useNaverTalkConsult: _useNaver,
      useInstaDmConsult: _useInstaDm,
      snsOperatingHours: InputSanitizer.sanitize(_snsHoursCtrl.text),
      agentRoles: _agentRoles,
    ));
    provider.setProfileCompleted(true);
    provider.generateAllDocuments();
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cs),
            _buildStepIndicator(cs),
            Expanded(child: PageView(controller: _pageController, physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(cs), _buildStep2(cs), _buildStep3(cs), _buildStep4(cs)])),
            _buildBottomBar(cs),
          ],
        ),
      ),
    );
  }

Widget _buildHeader(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1B64DA), Color(0xFF3B82F6)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 20)),
        const SizedBox(width: 10),
        Text('CS Builder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.5)),
        const Spacer(),
        TextButton(
          onPressed: () {
            final provider = context.read<AppProvider>();
            provider.setProfileCompleted(true);
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
          child: Text('건너뛰기', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4))),
        ),
      ]),
    );
  }
  Widget _buildStepIndicator(ColorScheme cs) {
    final steps = ['기본 정보', '채널 설정', '상담원', '외부 링크'];
    final icons = [Icons.business_rounded, Icons.cell_tower_rounded, Icons.people_alt_rounded, Icons.link_rounded];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: (isActive || isDone) ? const Color(0xFF1B64DA) : cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    boxShadow: isActive ? [BoxShadow(color: const Color(0xFF1B64DA).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : icons[i],
                    size: 16,
                    color: (isActive || isDone) ? Colors.white : cs.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                if (i < 3) Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF1B64DA) : cs.outlineVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1(ColorScheme cs) {
    return Form(key: _formKeys[0], child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), children: [
      _buildStepTitle('기본 정보', 'CS 운영 설계를 위한 사업 정보를 입력하세요', cs),
      const SizedBox(height: 20),
      _styledLabel('회사명 *', cs), TextFormField(controller: _companyNameCtrl, decoration: const InputDecoration(hintText: '예: 티파츠코리아'), validator: (v) => v!.isEmpty ? '필수 입력' : null),
      const SizedBox(height: 16),
      _styledLabel('브랜드명 *', cs), TextFormField(controller: _brandNameCtrl, decoration: const InputDecoration(hintText: '예: 티파츠'), validator: (v) => v!.isEmpty ? '필수 입력' : null),
      const SizedBox(height: 20),
      _styledLabel('업종 *', cs),
      _buildIndustryGrid(cs),
      if (_presetApplied && _industryType.isNotEmpty) Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B64DA).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1B64DA).withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF1B64DA)),
            const SizedBox(width: 8),
            Expanded(child: Text('업종 프리셋 적용 완료! 채널과 예산이 자동 설정되었습니다.', style: TextStyle(fontSize: 12, color: const Color(0xFF1B64DA), fontWeight: FontWeight.w500))),
          ]),
        ),
      ),
      if (_industryType.isEmpty) Padding(padding: const EdgeInsets.only(top: 4, left: 4), child: Text('업종을 선택해주세요', style: TextStyle(fontSize: 12, color: cs.error))),
      const SizedBox(height: 16),
      _styledLabel('주요 상품/서비스 *', cs), TextFormField(controller: _mainProductsCtrl, maxLines: 3, decoration: const InputDecoration(hintText: '예: 자동차 도어핸들, 요크핸들'), validator: (v) => v!.isEmpty ? '필수 입력' : null),
      const SizedBox(height: 16),
      _styledLabel('주요 고객층', cs), TextFormField(controller: _targetCustomerCtrl, decoration: const InputDecoration(hintText: '예: 테슬라 차량 오너')),
      const SizedBox(height: 24),
      _buildQuickStartCard(cs),
      const SizedBox(height: 80),
    ]));
  }

  Widget _buildIndustryGrid(ColorScheme cs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 1.3, crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: _industries.length,
      itemBuilder: (_, i) {
        final isSelected = _industryType == _industryKeys[i];
        return GestureDetector(
          onTap: () {
            setState(() { _industryType = isSelected ? '' : _industryKeys[i]; _presetApplied = false; });
            if (!isSelected) _applyPreset(_industryKeys[i]);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1B64DA) : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? Colors.transparent : cs.outlineVariant.withValues(alpha: 0.4)),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1B64DA).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_industryIcons[i], size: 22, color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.4)),
                const SizedBox(height: 4),
                Text(_industries[i], textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStartCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B64DA).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B64DA).withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: const Color(0xFF1B64DA), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.bolt_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text('빠른 시작', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ]),
        const SizedBox(height: 8),
        Text('필수 항목만 입력하면 프리셋이 나머지를 자동 설정합니다.\n나중에 설정에서 수정할 수 있어요.', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5), height: 1.5)),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: _quickStart,
          icon: const Icon(Icons.flash_on_rounded, size: 16),
          label: const Text('바로 생성하기'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: const Color(0xFF1B64DA).withValues(alpha: 0.3)),
            foregroundColor: const Color(0xFF1B64DA),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        )),
      ]),
    );
  }

  Widget _buildStep2(ColorScheme cs) {
    return Form(key: _formKeys[1], child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), children: [
      _buildStepTitle('채널 및 운영', 'CS 채널과 운영 자원을 설정하세요', cs),
      const SizedBox(height: 20),
      _styledLabel('상담원 수', cs),
      _buildCounter(value: _agentCount, min: 1, max: 10, onChanged: (v) => setState(() => _agentCount = v), suffix: '명', cs: cs),
      const SizedBox(height: 20),
      _styledLabel('일일 예상 문의 건수', cs),
      _buildCounter(value: _dailyCalls, min: 10, max: 500, step: 10, onChanged: (v) => setState(() => _dailyCalls = v), suffix: '건/일', cs: cs),
      const SizedBox(height: 20),
      _styledLabel('월 예산', cs),
      _buildBudgetSlider(cs),
      const SizedBox(height: 24),
      Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
      const SizedBox(height: 16),
      Text('채널 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.3)),
      const SizedBox(height: 16),
      _channelCard(icon: Icons.phone_rounded, title: '전화', subtitle: 'ARS/IVR + CTI', color: const Color(0xFF1B64DA), isActive: _usePhone, onToggle: (v) => setState(() => _usePhone = v), cs: cs, children: [
        TextFormField(controller: _phoneNumberCtrl, decoration: const InputDecoration(hintText: '대표번호', prefixIcon: Icon(Icons.phone, size: 18))),
        const SizedBox(height: 10),
        TextFormField(controller: _phoneHoursCtrl, decoration: const InputDecoration(hintText: '운영시간', prefixIcon: Icon(Icons.schedule, size: 18))),
      ]),
      const SizedBox(height: 10),
      _channelCard(icon: Icons.chat_rounded, title: '채널톡', subtitle: 'Channel Talk + ALF AI', color: const Color(0xFF3B82F6), isActive: _useChannelTalk, onToggle: (v) => setState(() => _useChannelTalk = v), cs: cs, children: [
        TextFormField(controller: _channelTalkIdCtrl, decoration: const InputDecoration(hintText: '채널 ID', prefixIcon: Icon(Icons.tag, size: 18))),
        const SizedBox(height: 10),
        TextFormField(controller: _channelTalkHoursCtrl, decoration: const InputDecoration(hintText: '운영시간', prefixIcon: Icon(Icons.schedule, size: 18))),
        const SizedBox(height: 10),
        SwitchListTile(value: _alfEnabled, onChanged: (v) => setState(() => _alfEnabled = v), title: const Text('ALF AI 자동응답', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: const Text('FAQ 기반 AI 자동 응답', style: TextStyle(fontSize: 12)), dense: true, contentPadding: EdgeInsets.zero),
      ]),
      const SizedBox(height: 10),
      _channelCard(icon: Icons.email_rounded, title: '이메일', subtitle: '고객 이메일 지원', color: const Color(0xFF2563EB), isActive: _useEmail, onToggle: (v) => setState(() => _useEmail = v), cs: cs, children: [
        TextFormField(controller: _supportEmailCtrl, decoration: const InputDecoration(hintText: '지원 이메일', prefixIcon: Icon(Icons.email, size: 18))),
        const SizedBox(height: 10),
        _styledLabel('응답 목표 시간', cs),
        SegmentedButton<int>(segments: const [ButtonSegment(value: 4, label: Text('4시간')), ButtonSegment(value: 12, label: Text('12시간')),
          ButtonSegment(value: 24, label: Text('24시간')), ButtonSegment(value: 48, label: Text('48시간'))],
          selected: {_emailResponseTarget}, onSelectionChanged: (v) => setState(() => _emailResponseTarget = v.first),
          style: ButtonStyle(textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)))),
      ]),
      const SizedBox(height: 10),
      _channelCard(icon: Icons.forum_rounded, title: 'SNS', subtitle: '카카오톡, 네이버, 인스타그램', color: const Color(0xFF60A5FA), isActive: _useSns, onToggle: (v) => setState(() => _useSns = v), cs: cs, children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilterChip(label: const Text('카카오톡'), selected: _useKakao, onSelected: (v) => setState(() => _useKakao = v), selectedColor: const Color(0xFF1B64DA).withValues(alpha: 0.12)),
          FilterChip(label: const Text('네이버 톡톡'), selected: _useNaver, onSelected: (v) => setState(() => _useNaver = v), selectedColor: const Color(0xFF1B64DA).withValues(alpha: 0.12)),
          FilterChip(label: const Text('인스타 DM'), selected: _useInstaDm, onSelected: (v) => setState(() => _useInstaDm = v), selectedColor: const Color(0xFF1B64DA).withValues(alpha: 0.12)),
        ]),
        const SizedBox(height: 10),
        TextFormField(controller: _snsHoursCtrl, decoration: const InputDecoration(hintText: 'SNS 운영시간', prefixIcon: Icon(Icons.schedule, size: 18))),
      ]),
      const SizedBox(height: 10),
      _channelCard(icon: Icons.dashboard_rounded, title: '게시판', subtitle: '공식몰 / Q&A 게시판', color: const Color(0xFF1E40AF), isActive: _useBoard, onToggle: (v) => setState(() => _useBoard = v), cs: cs, children: []),
      const SizedBox(height: 24),
      Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
      const SizedBox(height: 16),
      _styledLabel('매장 주소 (선택)', cs), TextFormField(controller: _storeAddressCtrl, decoration: const InputDecoration(hintText: '오프라인 매장이 있는 경우')),
      const SizedBox(height: 16), _styledLabel('영업 시간', cs), TextFormField(controller: _storeHoursCtrl, decoration: const InputDecoration(hintText: '예: 평일 10:00~19:00')),
      const SizedBox(height: 16), _styledLabel('주차 안내', cs), TextFormField(controller: _parkingInfoCtrl, decoration: const InputDecoration(hintText: '예: B1 무료주차 2시간')),
      const SizedBox(height: 100),
    ]));
  }

  Widget _buildBudgetSlider(ColorScheme cs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_formatBudget(_monthlyBudget), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1B64DA))),
      SliderTheme(
        data: SliderThemeData(
          activeTrackColor: const Color(0xFF1B64DA),
          inactiveTrackColor: cs.outlineVariant.withValues(alpha: 0.3),
          thumbColor: const Color(0xFF1B64DA),
          overlayColor: const Color(0xFF1B64DA).withValues(alpha: 0.1),
          trackHeight: 4,
        ),
        child: Slider(
          value: _monthlyBudget.toDouble(), min: 100000, max: 5000000, divisions: 49,
          onChanged: (v) => setState(() => _monthlyBudget = (v ~/ 100000) * 100000),
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('10만원', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.3))),
        Text('500만원', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.3))),
      ]),
    ]);
  }

  Widget _buildStep3(ColorScheme cs) {
    return Form(key: _formKeys[2], child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), children: [
      _buildStepTitle('상담원 역할', '${_agentCount}명 기준 자동 배치', cs),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B64DA).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF1B64DA)),
          const SizedBox(width: 8),
          Expanded(child: Text('상담원 수와 활성 채널을 기반으로 역할이 자동 배분됩니다.', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)))),
        ]),
      ),
      const SizedBox(height: 16),
      ..._agentRoles.asMap().entries.map((e) => _buildAgentCard(e.key, e.value, cs)),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _generateRoles,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('역할 재배치'),
        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1B64DA)),
      ),
      const SizedBox(height: 80),
    ]));
  }

  Widget _buildStep4(ColorScheme cs) {
    return Form(key: _formKeys[3], child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), children: [
      _buildStepTitle('외부 링크', '외부 채널 링크와 특이사항을 추가하세요', cs),
      const SizedBox(height: 24),
      _styledLabel('판매 채널', cs), TextFormField(controller: _salesChannelsCtrl, decoration: const InputDecoration(hintText: '예: 공식몰, 네이버 스마트스토어')),
      const SizedBox(height: 16), _styledLabel('웹사이트', cs), TextFormField(controller: _websiteCtrl, decoration: const InputDecoration(hintText: '예: tpartskorea.com')),
      const SizedBox(height: 16), _styledLabel('카카오톡 채널', cs), TextFormField(controller: _kakaoCtrl, decoration: const InputDecoration(hintText: '예: 티파츠')),
      const SizedBox(height: 16), _styledLabel('인스타그램', cs), TextFormField(controller: _instaCtrl, decoration: const InputDecoration(hintText: '예: @tpartskorea')),
      const SizedBox(height: 16), _styledLabel('특이사항', cs), TextFormField(controller: _specialNotesCtrl, maxLines: 4, decoration: const InputDecoration(hintText: '추가 고려사항이 있다면 입력하세요')),
      const SizedBox(height: 80),
    ]));
  }

  Widget _buildAgentCard(int idx, AgentRole role, ColorScheme cs) {
    final chNames = {'phone': '전화', 'channeltalk': '채널톡', 'email': '이메일', 'sns': 'SNS', 'board': '게시판'};
    final chIcons = {'phone': Icons.phone_rounded, 'channeltalk': Icons.chat_rounded, 'email': Icons.email_rounded, 'sns': Icons.forum_rounded, 'board': Icons.dashboard_rounded};
    final chColors = {'phone': const Color(0xFF1B64DA), 'channeltalk': const Color(0xFF3B82F6), 'email': const Color(0xFF2563EB), 'sns': const Color(0xFF60A5FA), 'board': const Color(0xFF1E40AF)};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: role.isPrimary ? const Color(0xFF1B64DA).withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: role.isPrimary ? const Color(0xFF1B64DA) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(child: Text(
              '${idx + 1}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: role.isPrimary ? Colors.white : cs.onSurface.withValues(alpha: 0.4)),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(role.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
            Text(role.title, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
          ])),
          if (role.isPrimary) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFF1B64DA), borderRadius: BorderRadius.circular(6)),
            child: const Text('Lead', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 6, runSpacing: 6, children: role.channels.map((ch) {
          final color = chColors[ch] ?? const Color(0xFF1B64DA);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(chIcons[ch] ?? Icons.circle, size: 13, color: color),
              const SizedBox(width: 4),
              Text(chNames[ch] ?? ch, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ]),
          );
        }).toList()),
        const SizedBox(height: 10),
        ...role.responsibilities.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 6, right: 8), decoration: BoxDecoration(color: const Color(0xFF1B64DA).withValues(alpha: 0.3), shape: BoxShape.circle)),
            Expanded(child: Text(r, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4))),
          ]),
        )),
      ]),
    );
  }

  Widget _channelCard({required IconData icon, required String title, required String subtitle, required Color color, required bool isActive,
    required ValueChanged<bool> onToggle, required ColorScheme cs, required List<Widget> children}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? color.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 8, 0), child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isActive ? color.withValues(alpha: 0.1) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: isActive ? color : cs.onSurface.withValues(alpha: 0.3)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.4))),
            Text(subtitle, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.35))),
          ])),
          Switch(value: isActive, onChanged: onToggle, activeColor: const Color(0xFF1B64DA)),
        ])),
        if (isActive && children.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
      ]),
    );
  }

  Widget _buildStepTitle(String title, String subtitle, ColorScheme cs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.5)),
      const SizedBox(height: 4),
      Text(subtitle, style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.4))),
    ]);
  }

  Widget _styledLabel(String text, ColorScheme cs) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.55))),
  );

  Widget _buildCounter({required int value, required int min, required int max, int step = 1, required Function(int) onChanged, required String suffix, required ColorScheme cs}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4))),
      child: Row(children: [
        _counterBtn(Icons.remove_rounded, value > min ? () => onChanged(value - step) : null, cs),
        Expanded(child: Center(child: Text('$value $suffix', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface)))),
        _counterBtn(Icons.add_rounded, value < max ? () => onChanged(value + step) : null, cs),
      ]),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback? onPressed, ColorScheme cs) {
    return Material(
      color: onPressed != null ? const Color(0xFF1B64DA).withValues(alpha: 0.08) : cs.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40, height: 40,
          child: Icon(icon, size: 20, color: onPressed != null ? const Color(0xFF1B64DA) : cs.onSurface.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(children: [
        if (_currentStep > 0) Expanded(child: OutlinedButton(
          onPressed: _prevStep,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            foregroundColor: const Color(0xFF1B64DA),
            side: BorderSide(color: const Color(0xFF1B64DA).withValues(alpha: 0.3)),
          ),
          child: const Text('이전'),
        )),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: _currentStep > 0 ? 2 : 1,
          child: ElevatedButton(
            onPressed: (_industryType.isNotEmpty || _currentStep > 0) ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B64DA),
              foregroundColor: Colors.white,
              disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.1),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(_currentStep < 3 ? '다음' : '문서 생성하기', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  String _formatBudget(int amount) {
    if (amount >= 10000) {
      final man = amount ~/ 10000;
      final rem = amount % 10000;
      return rem == 0 ? '${man}만원' : '${man}만 ${rem}원';
    }
    return '${amount}원';
  }
}