class BusinessProfile {
  String companyName;
  String brandName;
  String industryType;
  String businessCategory;
  String targetCustomer;
  String mainProducts;
  String salesChannels;
  int agentCount;
  int monthlyBudget;
  int dailyCalls;
  String operatingHours;
  String storeAddress;
  String storeHours;
  String parkingInfo;
  String websiteUrl;
  String kakaoChannel;
  String instagramId;
  String naverTalkId;
  String emailAddress;
  String specialNotes;

  bool usePhoneChannel;
  bool useChannelTalk;
  bool useEmailChannel;
  bool useSnsChannel;
  bool useBoardChannel;

  String phoneNumber;
  String phoneOperatingHours;
  String channelTalkId;
  String channelTalkOperatingHours;
  bool channelTalkAlfEnabled;
  String supportEmail;
  int emailResponseTarget;
  bool useKakaoConsult;
  bool useNaverTalkConsult;
  bool useInstaDmConsult;
  String snsOperatingHours;

  List<AgentRole> agentRoles;

  BusinessProfile({
    this.companyName = '',
    this.brandName = '',
    this.industryType = '',
    this.businessCategory = '',
    this.targetCustomer = '',
    this.mainProducts = '',
    this.salesChannels = '',
    this.agentCount = 1,
    this.monthlyBudget = 500000,
    this.dailyCalls = 50,
    this.operatingHours = '09:00~18:00',
    this.storeAddress = '',
    this.storeHours = '',
    this.parkingInfo = '',
    this.websiteUrl = '',
    this.kakaoChannel = '',
    this.instagramId = '',
    this.naverTalkId = '',
    this.emailAddress = '',
    this.specialNotes = '',
    this.usePhoneChannel = true,
    this.useChannelTalk = true,
    this.useEmailChannel = false,
    this.useSnsChannel = true,
    this.useBoardChannel = true,
    this.phoneNumber = '',
    this.phoneOperatingHours = '09:00~18:00',
    this.channelTalkId = '',
    this.channelTalkOperatingHours = '09:00~18:00',
    this.channelTalkAlfEnabled = true,
    this.supportEmail = '',
    this.emailResponseTarget = 24,
    this.useKakaoConsult = true,
    this.useNaverTalkConsult = false,
    this.useInstaDmConsult = false,
    this.snsOperatingHours = '09:00~18:00',
    List<AgentRole>? agentRoles,
  }) : agentRoles = agentRoles ?? [];

  List<String> get activeChannels {
    final list = <String>[];
    if (usePhoneChannel) list.add('phone');
    if (useChannelTalk) list.add('channeltalk');
    if (useEmailChannel) list.add('email');
    if (useSnsChannel) list.add('sns');
    if (useBoardChannel) list.add('board');
    return list;
  }

  String get activeChannelsSummary {
    final parts = <String>[];
    if (usePhoneChannel) parts.add('전화');
    if (useChannelTalk) parts.add('채널톡');
    if (useEmailChannel) parts.add('이메일');
    if (useSnsChannel) parts.add('SNS');
    if (useBoardChannel) parts.add('게시판');
    return parts.join(', ');
  }

  List<String> get activeSnsChannels {
    final list = <String>[];
    if (useKakaoConsult) list.add('카카오톡');
    if (useNaverTalkConsult) list.add('네이버 톡톡');
    if (useInstaDmConsult) list.add('인스타그램 DM');
    return list;
  }

  List<AgentRole> generateDefaultRoles() {
    final roles = <AgentRole>[];
    final channels = activeChannels;

    if (agentCount == 1) {
      roles.add(AgentRole(
        name: '상담원 1',
        title: '총괄 상담원',
        channels: List.from(channels),
        responsibilities: ['전 채널 고객 상담 총괄', '콜 우선 대응 원칙 적용', 'ALF 자동 응답 모니터링', '게시판 하루 2회 정기 확인', 'VOC 주간 정리'],
        isPrimary: true,
      ));
    } else if (agentCount == 2) {
      roles.add(AgentRole(
        name: '상담원 A', title: '제품 상담 주담당',
        channels: channels.where((c) => c == 'phone' || c == 'sns' || c == 'channeltalk').toList(),
        responsibilities: ['인바운드 콜 상담 (실시간)', 'SNS 채팅 상담 (실시간)', '채널톡 실시간 응대', '제품/서비스 전문 상담', '신규 고객 응대'],
        isPrimary: true,
      ));
      roles.add(AgentRole(
        name: '상담원 B', title: 'B2B/비실시간 담당',
        channels: channels.where((c) => c == 'email' || c == 'board' || c == 'phone').toList(),
        responsibilities: ['B2B 문의 전담', '이메일 상담 처리', '게시판 답변 작성', 'VOC 데이터 수집/분석', '콜 백업 (피크타임)'],
        isPrimary: false,
      ));
    } else if (agentCount == 3) {
      roles.add(AgentRole(name: '상담원 A', title: '전화 상담 주담당', channels: ['phone'],
        responsibilities: ['인바운드 콜 전담', 'IVR 미처리 콜 응대', '콜백 처리', '전화 상담 품질 관리'], isPrimary: true));
      roles.add(AgentRole(name: '상담원 B', title: '온라인 채널 담당', channels: ['channeltalk', 'sns'],
        responsibilities: ['채널톡 실시간 응대', 'SNS 상담', 'ALF 자동 응답 모니터링', '워크플로우 관리'], isPrimary: false));
      roles.add(AgentRole(name: '상담원 C', title: '비실시간/B2B 담당', channels: ['email', 'board'],
        responsibilities: ['이메일 상담 전담', '게시판 Q&A 답변', 'B2B 문의 처리', 'VOC 분석/리포트', '교환/반품/AS 후속 처리'], isPrimary: false));
    } else {
      roles.add(AgentRole(name: '상담원 A', title: '전화 상담 리더', channels: ['phone'],
        responsibilities: ['인바운드 콜 리더', '상담 품질(QA) 관리', '에스컬레이션 1차 판단', '신입 상담원 코칭'], isPrimary: true));
      roles.add(AgentRole(name: '상담원 B', title: '전화 상담 서브', channels: ['phone'],
        responsibilities: ['인바운드 콜 서브 담당', '콜백 처리', '피크타임 분산 대응', 'A 상담원 부재 시 백업'], isPrimary: false));
      roles.add(AgentRole(name: '상담원 C', title: '온라인 채널 전담', channels: ['channeltalk', 'sns'],
        responsibilities: ['채널톡 실시간 응대', 'SNS 상담 전담', 'ALF 자동 응답 관리', '워크플로우 최적화'], isPrimary: false));
      for (int i = 3; i < agentCount; i++) {
        final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
        roles.add(AgentRole(
          name: '상담원 $letter',
          title: i == 3 ? '이메일/게시판/B2B 담당' : '유연 배치 상담원',
          channels: i == 3 ? ['email', 'board'] : List.from(channels),
          responsibilities: i == 3
              ? ['이메일 상담 전담', '게시판 Q&A 답변', 'B2B 문의 처리', 'VOC 분석/리포트']
              : ['피크타임 전 채널 지원', '미처리건 백업 대응', '특수 프로젝트 지원', '교육/QA 참여'],
          isPrimary: false,
        ));
      }
    }
    return roles;
  }

  Map<String, dynamic> toMap() => {
    'companyName': companyName, 'brandName': brandName, 'industryType': industryType,
    'businessCategory': businessCategory, 'targetCustomer': targetCustomer,
    'mainProducts': mainProducts, 'salesChannels': salesChannels,
    'agentCount': agentCount, 'monthlyBudget': monthlyBudget, 'dailyCalls': dailyCalls,
    'operatingHours': operatingHours, 'storeAddress': storeAddress,
    'storeHours': storeHours, 'parkingInfo': parkingInfo, 'websiteUrl': websiteUrl,
    'kakaoChannel': kakaoChannel, 'instagramId': instagramId, 'naverTalkId': naverTalkId,
    'emailAddress': emailAddress, 'specialNotes': specialNotes,
    'usePhoneChannel': usePhoneChannel, 'useChannelTalk': useChannelTalk,
    'useEmailChannel': useEmailChannel, 'useSnsChannel': useSnsChannel,
    'useBoardChannel': useBoardChannel, 'phoneNumber': phoneNumber,
    'phoneOperatingHours': phoneOperatingHours, 'channelTalkId': channelTalkId,
    'channelTalkOperatingHours': channelTalkOperatingHours,
    'channelTalkAlfEnabled': channelTalkAlfEnabled, 'supportEmail': supportEmail,
    'emailResponseTarget': emailResponseTarget, 'useKakaoConsult': useKakaoConsult,
    'useNaverTalkConsult': useNaverTalkConsult, 'useInstaDmConsult': useInstaDmConsult,
    'snsOperatingHours': snsOperatingHours,
    'agentRoles': agentRoles.map((r) => r.toMap()).toList(),
  };

  factory BusinessProfile.fromMap(Map<String, dynamic> map) => BusinessProfile(
    companyName: map['companyName'] ?? '', brandName: map['brandName'] ?? '',
    industryType: map['industryType'] ?? '', businessCategory: map['businessCategory'] ?? '',
    targetCustomer: map['targetCustomer'] ?? '', mainProducts: map['mainProducts'] ?? '',
    salesChannels: map['salesChannels'] ?? '', agentCount: map['agentCount'] ?? 1,
    monthlyBudget: map['monthlyBudget'] ?? 500000, dailyCalls: map['dailyCalls'] ?? 50,
    operatingHours: map['operatingHours'] ?? '09:00~18:00',
    storeAddress: map['storeAddress'] ?? '', storeHours: map['storeHours'] ?? '',
    parkingInfo: map['parkingInfo'] ?? '', websiteUrl: map['websiteUrl'] ?? '',
    kakaoChannel: map['kakaoChannel'] ?? '', instagramId: map['instagramId'] ?? '',
    naverTalkId: map['naverTalkId'] ?? '', emailAddress: map['emailAddress'] ?? '',
    specialNotes: map['specialNotes'] ?? '',
    usePhoneChannel: map['usePhoneChannel'] ?? true, useChannelTalk: map['useChannelTalk'] ?? true,
    useEmailChannel: map['useEmailChannel'] ?? false, useSnsChannel: map['useSnsChannel'] ?? true,
    useBoardChannel: map['useBoardChannel'] ?? true,
    phoneNumber: map['phoneNumber'] ?? '', phoneOperatingHours: map['phoneOperatingHours'] ?? '09:00~18:00',
    channelTalkId: map['channelTalkId'] ?? '',
    channelTalkOperatingHours: map['channelTalkOperatingHours'] ?? '09:00~18:00',
    channelTalkAlfEnabled: map['channelTalkAlfEnabled'] ?? true,
    supportEmail: map['supportEmail'] ?? '', emailResponseTarget: map['emailResponseTarget'] ?? 24,
    useKakaoConsult: map['useKakaoConsult'] ?? true,
    useNaverTalkConsult: map['useNaverTalkConsult'] ?? false,
    useInstaDmConsult: map['useInstaDmConsult'] ?? false,
    snsOperatingHours: map['snsOperatingHours'] ?? '09:00~18:00',
    agentRoles: (map['agentRoles'] as List?)?.map((r) => AgentRole.fromMap(r as Map<String, dynamic>)).toList() ?? [],
  );

  bool get isComplete => companyName.isNotEmpty && brandName.isNotEmpty && industryType.isNotEmpty && mainProducts.isNotEmpty;
}

class AgentRole {
  String name;
  String title;
  List<String> channels;
  List<String> responsibilities;
  bool isPrimary;

  AgentRole({required this.name, required this.title, this.channels = const [],
    this.responsibilities = const [], this.isPrimary = false});

  Map<String, dynamic> toMap() => {
    'name': name, 'title': title, 'channels': channels,
    'responsibilities': responsibilities, 'isPrimary': isPrimary,
  };

  factory AgentRole.fromMap(Map<String, dynamic> map) => AgentRole(
    name: map['name'] ?? '', title: map['title'] ?? '',
    channels: List<String>.from(map['channels'] ?? []),
    responsibilities: List<String>.from(map['responsibilities'] ?? []),
    isPrimary: map['isPrimary'] ?? false,
  );
}
