import '../models/business_profile.dart';
import '../models/generated_documents.dart';

class DocumentGeneratorService {
  static List<FAQItem> generateFAQ(BusinessProfile profile) {
    final List<FAQItem> faqs = [];
    final brand = profile.brandName.isEmpty ? profile.companyName : profile.brandName;
    final industry = profile.industryType;
    final products = profile.mainProducts;
    final website = profile.websiteUrl.isEmpty ? '[공식 홈페이지]' : profile.websiteUrl;
    final kakao = profile.kakaoChannel.isEmpty ? brand : profile.kakaoChannel;
    final address = profile.storeAddress.isEmpty ? '[매장 주소]' : profile.storeAddress;
    final storeHrs = profile.storeHours.isEmpty ? '평일 10:00~19:00' : profile.storeHours;
    final parking = profile.parkingInfo.isEmpty ? '건물 주차장 이용 가능' : profile.parkingInfo;
    final opHrs = profile.operatingHours;
    final channelSummary = profile.activeChannelsSummary;
    int faqNum = 1;
    String faqId() => 'FAQ-${faqNum.toString().padLeft(2, '0')}';

    faqs.add(FAQItem(id: faqId(), category: '매장/운영', channel: '전체',
      question: '$brand 오프라인 매장은 어디에 있나요?',
      answer: '$brand 매장은 $address에 위치하고 있습니다. 네이버 지도에서 \'$brand\'를 검색하시면 길안내를 받으실 수 있어요.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '매장/운영', channel: '전체',
      question: '매장 영업시간이 어떻게 되나요?',
      answer: '$brand 매장 영업시간은 $storeHrs입니다. 방문 전 카카오톡 \'$kakao\'로 사전 문의하시면 대기 없이 바로 상담받으실 수 있어요!')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '매장/운영', channel: '전체',
      question: '주차가 가능한가요?',
      answer: '네, $parking. 편하게 방문해 주세요.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '매장/운영', channel: '전체',
      question: '고객센터 상담 채널은 어떤 것이 있나요?',
      answer: '$brand 고객센터는 $channelSummary 채널을 통해 운영됩니다. 상담 운영시간은 $opHrs이며, 업무 외 시간에는 AI 자동 응답으로 기본 안내를 받으실 수 있습니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '매장/운영', channel: '전체',
      question: '예약은 어떻게 하나요?',
      answer: '예약은 카카오톡 채널 \'$kakao\'에서 24시간 접수 가능합니다. 희망 날짜/시간을 남겨주시면 영업일 기준 4시간 이내에 확정 연락을 드립니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '매장/운영', channel: '전체',
      question: '서비스 소요 시간은 얼마나 걸리나요?',
      answer: _getServiceTimeByIndustry(industry, products))); faqNum++;

    final productFaqs = _generateIndustryFAQs(profile, faqNum);
    faqs.addAll(productFaqs);
    faqNum += productFaqs.length;

    faqs.add(FAQItem(id: faqId(), category: '주문/배송', channel: '전체', question: '배송은 얼마나 걸리나요?', answer: '국내 배송은 결제 완료 후 영업일 기준 1~2일 이내 출고되며, 출고 후 2~3일 내 수령 가능합니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '주문/배송', channel: '전체', question: '배송비는 얼마인가요?', answer: '기본 배송비는 3,000원이며, 일정 금액 이상 구매 시 무료배송이 적용됩니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '주문/배송', channel: '전체', question: '주문 후 취소나 변경이 가능한가요?', answer: '출고 전(결제 후 영업일 기준 1일 이내)에는 고객센터 연락 또는 마이페이지에서 취소/변경이 가능합니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '주문/배송', channel: '전체', question: '주문 조회는 어떻게 하나요?', answer: '$website에 로그인하신 후 \'마이페이지 > 주문조회\'에서 확인하실 수 있습니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '주문/배송', channel: '전체', question: '결제 수단은 어떤 것이 있나요?', answer: '신용카드, 실시간 계좌이체, 네이버페이, 카카오페이, 토스페이 등 다양한 결제 수단을 지원합니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '주문/배송', channel: '전체', question: '묶음 배송이 되나요?', answer: '네, 동시에 주문하신 제품은 묶음 배송으로 처리됩니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '주문/배송', channel: '전체', question: '해외 배송도 가능한가요?', answer: '현재는 국내 배송만 지원하고 있습니다. 해외 배송이 필요하신 경우 고객센터로 별도 문의해 주세요.')); faqNum++;

    faqs.add(FAQItem(id: faqId(), category: '교환/반품/AS', channel: '전체', question: '교환이나 반품은 어떻게 하나요?', answer: '제품 수령일로부터 7일 이내, 미개봉/미사용 상태의 제품에 한해 교환/반품이 가능합니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '교환/반품/AS', channel: '전체', question: '제품이 불량인 것 같은데 어떻게 하나요?', answer: '불량 제품은 수령 후 즉시 고객센터로 연락해 주세요. 사진과 증상 확인 후, 무상 교환 또는 환불 처리됩니다.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '교환/반품/AS', channel: '전체', question: '품질 보증은 어떻게 되나요?', answer: _getWarrantyByIndustry(industry, brand))); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: '교환/반품/AS', channel: '전체', question: 'AS 접수는 어떻게 하나요?', answer: 'AS는 고객센터($channelSummary)를 통해 접수 가능합니다.')); faqNum++;

    faqs.add(FAQItem(id: faqId(), category: 'B2B/제휴', channel: '전체', question: '도매나 대리점 문의는 어떻게 하나요?', answer: 'B2B 도매/대리점 문의는 카카오톡 \'$kakao\'에서 \'B2B 문의\'를 선택해 주세요.')); faqNum++;
    faqs.add(FAQItem(id: faqId(), category: 'B2B/제휴', channel: '전체', question: '공동구매나 제휴 제안이 가능한가요?', answer: '다양한 형태의 제휴/공동구매를 환영합니다! 카카오톡 \'$kakao\'에서 제안 내용을 남겨주세요.'));

    return faqs;
  }

  static List<FAQItem> _generateIndustryFAQs(BusinessProfile profile, int startNum) {
    final brand = profile.brandName.isEmpty ? profile.companyName : profile.brandName;
    final industry = profile.industryType;
    final website = profile.websiteUrl.isEmpty ? '[공식 홈페이지]' : profile.websiteUrl;
    final kakao = profile.kakaoChannel.isEmpty ? brand : profile.kakaoChannel;
    int n = startNum;
    String faqId() { final id = 'FAQ-${n.toString().padLeft(2, '0')}'; n++; return id; }
    final List<FAQItem> faqs = [];

    faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '대표 상품은 어떤 것이 있나요?', answer: '$brand의 주요 제품 라인업은 ${profile.mainProducts} 등이 있습니다. $website에서 확인해 주세요.'));
    faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '가장 인기 있는 제품은 무엇인가요?', answer: '$website의 BEST 카테고리에서 실시간 인기 제품을 확인하실 수 있어요!'));
    faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '할인이나 프로모션 정보를 어디서 확인하나요?', answer: '카카오톡 \'$kakao\' 채널에서 확인 가능합니다. 채널을 추가하시면 할인 소식을 가장 먼저 받아보실 수 있어요!'));

    switch (industry) {
      case '자동차/튜닝':
        faqs.add(FAQItem(id: faqId(), category: '상품문의/호환성', channel: '전화', question: '제 차량에 맞는 제품이 있나요?', answer: '차량 모델과 연식을 알려주시면 정확한 호환 제품을 안내드립니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의/호환성', channel: '전체', question: '구형과 신형 차량은 호환이 되나요?', answer: '차량 구형과 신형은 내부 구조가 다른 경우가 많아 전용 제품의 호환이 안 될 수 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '시공/설치', channel: '전체', question: 'DIY 셀프 시공이 가능한가요?', answer: '인테리어 악세사리는 대부분 셀프 시공이 가능하지만, 전장류는 전문 시공점을 권장합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '시공/설치', channel: '전체', question: '시공 후 문제가 발생하면 어떻게 하나요?', answer: '매장 시공 제품은 시공 품질까지 보증합니다. 즉시 고객센터로 연락해 주세요.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '순정 부품과 어떤 차이가 있나요?', answer: '$brand 제품은 순정 규격에 맞춰 제작된 프리미엄 애프터마켓 제품입니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: 'SNS', question: '시공 전후 사진을 볼 수 있나요?', answer: '인스타그램에서 실제 시공 사례와 전후 비교 사진을 확인하실 수 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '출장 시공도 가능한가요?', answer: '현재 출장 시공은 별도 문의가 필요합니다. 지역과 제품에 따라 안내드립니다.'));
        break;
      case '음식/외식':
        faqs.add(FAQItem(id: faqId(), category: '메뉴/알레르기', channel: '전체', question: '알레르기 정보를 알 수 있나요?', answer: '모든 메뉴의 알레르기 정보는 매장 메뉴판과 $website에서 확인 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '메뉴/알레르기', channel: '전체', question: '비건/채식 메뉴가 있나요?', answer: '채식 옵션을 제공하고 있습니다. 메뉴판에 채식 마크로 구분되어 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '주문', channel: '전체', question: '단체 주문이 가능한가요?', answer: '네, 단체 주문과 케이터링 서비스를 제공합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '주문', channel: '전체', question: '배달 서비스를 이용할 수 있나요?', answer: '배달앱 또는 자체 배달 서비스를 통해 주문 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '메뉴', channel: '전체', question: '메뉴 커스터마이징이 가능한가요?', answer: '일부 메뉴는 커스터마이징이 가능합니다. 주문 시 요청해 주세요.'));
        faqs.add(FAQItem(id: faqId(), category: '매장', channel: '전체', question: '아이 동반 방문이 가능한가요?', answer: '아이 동반 방문을 환영합니다! 유아 의자와 키즈 메뉴를 준비하고 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '매장', channel: '전체', question: '원재료는 어디서 공급받나요?', answer: '$brand는 신선하고 검증된 원재료만을 사용합니다.'));
        break;
      case '뷰티/미용':
        faqs.add(FAQItem(id: faqId(), category: '시술/예약', channel: '전체', question: '시술 전 상담이 필요한가요?', answer: '첫 방문 시 5~10분 정도의 사전 상담을 진행합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '시술', channel: '전체', question: '민감성 피부에도 시술이 가능한가요?', answer: '민감성 피부 전용 제품과 프로그램을 운영하고 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '시술', channel: '전체', question: '시술 후 주의사항이 있나요?', answer: '일반적으로 24시간 내 자극적인 세안이나 사우나를 피하시는 것이 좋습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품', channel: '전체', question: '홈케어 제품도 판매하나요?', answer: '네, $website에서도 구매 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '예약', channel: '전체', question: '당일 예약이 가능한가요?', answer: '시간대별 여유가 있는 경우 가능합니다. 카카오톡 \'$kakao\'로 문의해 주세요.'));
        faqs.add(FAQItem(id: faqId(), category: '멤버십', channel: '전체', question: '멤버십이나 포인트 제도가 있나요?', answer: '방문 횟수 및 결제 금액에 따른 멤버십 등급 제도를 운영하고 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '시술', channel: 'SNS', question: '시술 결과 사진을 볼 수 있나요?', answer: '인스타그램에 시술 전후 사진을 게시하고 있습니다.'));
        break;
      case 'IT/전자':
        faqs.add(FAQItem(id: faqId(), category: '기술지원', channel: '전화', question: '설치/설정에 도움이 필요합니다.', answer: '원격 지원 또는 전화 가이드를 통해 도와드립니다.'));
        faqs.add(FAQItem(id: faqId(), category: '기술지원', channel: '전체', question: '소프트웨어 업데이트는 어떻게 하나요?', answer: '$website에서 다운로드 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '기술지원', channel: '이메일', question: '기술적인 문제가 발생했습니다.', answer: '제품명, 에러 메시지, 발생 상황을 상세히 알려주세요.'));
        faqs.add(FAQItem(id: faqId(), category: '호환성', channel: '전체', question: 'OS 호환성은 어떤가요?', answer: '각 제품의 지원 OS 목록은 제품 상세 페이지에서 확인 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '라이선스', channel: '전체', question: '라이선스는 몇 대까지 사용 가능한가요?', answer: '기본 라이선스는 1인 1기기 기준입니다. 멀티디바이스 라이선스도 별도 제공합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '기술지원', channel: '채널톡', question: '원격 지원을 받을 수 있나요?', answer: '네, 채널톡 또는 전화를 통해 원격 지원이 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '보안', channel: '전체', question: '개인정보는 안전하게 보호되나요?', answer: '$brand는 개인정보보호법을 철저히 준수합니다.'));
        break;
      case '패션/의류':
        faqs.add(FAQItem(id: faqId(), category: '사이즈', channel: '전체', question: '사이즈 선택이 어려운데 어떻게 하나요?', answer: '각 제품 페이지에 상세 사이즈 차트가 제공됩니다.'));
        faqs.add(FAQItem(id: faqId(), category: '사이즈', channel: 'SNS', question: '사이즈 교환은 무료인가요?', answer: '첫 교환에 한해 무료 사이즈 교환을 지원합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품', channel: '전체', question: '신상품은 언제 입고되나요?', answer: '카카오톡 \'$kakao\' 채널에서 가장 먼저 공개됩니다.'));
        faqs.add(FAQItem(id: faqId(), category: '세탁/관리', channel: '전체', question: '세탁/관리 방법을 알 수 있나요?', answer: '제품에 세탁 가이드가 표기되어 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품', channel: '전체', question: '실물 색상이 다를 수 있나요?', answer: '모니터 환경에 따라 약간 차이가 있을 수 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품', channel: '전체', question: '품절된 상품은 재입고되나요?', answer: '재입고 알림을 설정하시면 입고 즉시 알림을 보내드립니다.'));
        faqs.add(FAQItem(id: faqId(), category: '코디', channel: 'SNS', question: '코디 추천을 받을 수 있나요?', answer: '카카오톡 \'$kakao\'에서 스타일링 상담을 받으실 수 있어요!'));
        break;
      case '건강/의료':
        faqs.add(FAQItem(id: faqId(), category: '상담/예약', channel: '전체', question: '초진 예약은 어떻게 하나요?', answer: '전화 또는 카카오톡 \'$kakao\'를 통해 예약 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품', channel: '전체', question: '건강기능식품의 인증 정보를 알 수 있나요?', answer: '모든 건강기능식품은 식약처 인증을 받은 제품입니다.'));
        faqs.add(FAQItem(id: faqId(), category: '복용', channel: '전체', question: '다른 약과 같이 먹어도 되나요?', answer: '전문가 상담을 권장드립니다. 고객센터를 통해 상담 연결이 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '배송', channel: '전체', question: '냉장 보관 제품도 배송이 가능한가요?', answer: '네, 아이스팩과 보냉 포장으로 안전하게 배송됩니다.'));
        faqs.add(FAQItem(id: faqId(), category: '정기구독', channel: '전체', question: '정기 구독 서비스가 있나요?', answer: '인기 제품은 정기 구독 서비스를 제공하고 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품', channel: '전체', question: '제품의 유통기한은 어떻게 되나요?', answer: '최소 6개월 이상의 유통기한이 남은 상태로 발송됩니다.'));
        faqs.add(FAQItem(id: faqId(), category: '반품', channel: '전체', question: '건강기능식품도 반품이 가능한가요?', answer: '미개봉 제품에 한해 반품이 가능합니다.'));
        break;
      case '교육/학습':
        faqs.add(FAQItem(id: faqId(), category: '수강/등록', channel: '전체', question: '수강 신청은 어떻게 하나요?', answer: '$website에서 온라인으로 수강 신청이 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '수강', channel: '전체', question: '무료 체험 수업이 있나요?', answer: '첫 수강생에 한해 무료 체험 수업을 제공합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '수강', channel: '전체', question: '수업 시간 변경이 가능한가요?', answer: '수업 시작 24시간 전까지 변경이 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '환불', channel: '전체', question: '수강료 환불 규정은 어떻게 되나요?', answer: '수강 시작 전 전액 환불, 1/3 경과 전 2/3 환불, 1/2 경과 전 1/2 환불입니다.'));
        faqs.add(FAQItem(id: faqId(), category: '교재', channel: '전체', question: '교재는 별도 구매해야 하나요?', answer: '기본 교재는 수강료에 포함되어 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '수강', channel: '전체', question: '온라인 수업도 가능한가요?', answer: 'Zoom 또는 자체 플랫폼을 통한 온라인 실시간 수업을 제공합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '수료', channel: '전체', question: '수료증이 발급되나요?', answer: '커리큘럼 이수 후 수료증을 발급해 드립니다.'));
        break;
      default:
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '제품 상세 사양을 알 수 있나요?', answer: '$website의 제품 상세 페이지에서 확인 가능합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '대량 구매 시 할인이 되나요?', answer: '별도 견적을 안내드립니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '제품 사용법이 어려운데 도움을 받을 수 있나요?', answer: '사용 가이드를 $website과 유튜브에서 제공하고 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '제품의 소재/품질은 어떤가요?', answer: '$brand는 프리미엄 소재만을 사용합니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: 'SNS', question: '신제품 출시 소식은 어디서 확인하나요?', answer: '카카오톡 \'$kakao\' 채널에서 가장 먼저 받아보실 수 있어요!'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '제품 실물을 직접 볼 수 있나요?', answer: '오프라인 매장에서 직접 보시고 체험하실 수 있습니다.'));
        faqs.add(FAQItem(id: faqId(), category: '상품문의', channel: '전체', question: '제품 후기를 볼 수 있나요?', answer: '$website의 제품 페이지 하단에서 확인 가능합니다.'));
        break;
    }
    return faqs;
  }

  static String _getServiceTimeByIndustry(String industry, String products) {
    switch (industry) {
      case '자동차/튜닝': return '제품별 시공 시간이 다릅니다. 간단한 악세사리는 약 10~30분, 전장류는 약 1~3시간이 소요됩니다.';
      case '음식/외식': return '일반 주문은 약 15~30분 내 준비됩니다.';
      case '뷰티/미용': return '기본 시술은 약 30분~1시간, 풀 패키지 시술은 약 2~3시간이 소요됩니다.';
      case 'IT/전자': return '간단한 점검은 약 30분, 수리/설치는 1~2시간이 소요됩니다.';
      case '패션/의류': return '온라인 주문은 결제 후 1~2영업일 내 출고됩니다.';
      case '건강/의료': return '기본 상담은 약 15~30분, 정밀 검사는 1~2시간이 소요됩니다.';
      case '교육/학습': return '수업 시간은 과정별로 다릅니다. 일반 수업은 1~2시간입니다.';
      default: return '기본 서비스는 약 30분~1시간이 소요됩니다.';
    }
  }

  static String _getWarrantyByIndustry(String industry, String brand) {
    switch (industry) {
      case '자동차/튜닝': return '$brand 전 제품은 구매일로부터 1년간 품질 보증을 제공합니다. 매장 시공 제품은 시공 품질까지 보증합니다.';
      case 'IT/전자': return '$brand 전 제품은 구매일로부터 1년간 무상 보증을 제공합니다. 소프트웨어는 무상 업데이트로 지원합니다.';
      case '뷰티/미용': return '$brand 시술은 시술 후 2주간 무상 재시술을 보장합니다.';
      default: return '$brand 전 제품은 구매일로부터 1년간 품질 보증을 제공합니다.';
    }
  }

  // ==================== QA SHEET GENERATOR ====================
  static QAEvaluationSheet generateQASheet(BusinessProfile profile) {
    final brand = profile.brandName.isEmpty ? profile.companyName : profile.brandName;
    return QAEvaluationSheet(
      title: '$brand 고객센터 QA 평가 시트',
      criteria: [
        QACriteria(name: '인사/마무리', description: '인사 및 마무리', scoreGuide: [
          '5점: 표준 인사 정확히 준수, 종료 시 추가 문의 확인 + 감사 인사',
          '4점: 인사 또는 마무리 중 한 가지가 약간 미흡',
          '3점: 인사는 했으나 형식적, 마무리 시 추가 문의 확인 누락',
          '2점: 인사 또는 마무리 중 하나를 생략',
          '1점: 인사와 마무리 모두 부재 또는 부적절',
        ]),
        QACriteria(name: '경청/공감', description: '경감 및 공감', scoreGuide: [
          '5점: 고객 문의를 정확히 요약/반복하여 확인, 자연스러운 공감 표현',
          '4점: 문의 파악은 정확하나 공감 표현이 다소 부족',
          '3점: 재확인 필요했으나 최종적으로 정확히 이해',
          '2점: 고객 의도를 오해하여 수정',
          '1점: 고객의 말을 끊거나 문의 내용을 잘못 파악',
        ]),
        QACriteria(name: '정확성', description: '정확성', scoreGuide: [
          '5점: 제품 정보, 정책, 매장 정보를 모두 정확하게 안내',
          '4점: 핵심 정보는 정확하나 부가 정보에 경미한 부정확 1건',
          '3점: 주요 안내 중 1건의 오류가 있었으나 큰 영향 없음',
          '2점: 핵심 안내에 오류가 있어 고객이 혼란',
          '1점: 복수의 중요 정보에 오류',
        ]),
        QACriteria(name: '해결력', description: '해결력', scoreGuide: [
          '5점: 1차 완결(FCR) 달성, 고객 만족 종료',
          '4점: 1차 완결이나 다소 시간 소요',
          '3점: 1차 완결 불가했으나 적절한 에스컬레이션',
          '2점: 에스컬레이션 기준에 해당하나 직접 해결하려다 지연',
          '1점: 해결 없이 종료 또는 부적절한 방법으로 상담 종료',
        ]),
        QACriteria(name: '톤앤매너', description: '톤 및 매너', scoreGuide: [
          '5점: 브랜드에 맞는 정중하되 전문적인 어조 유지',
          '4점: 전체적으로 양호하나 일부 구간에서 캐주얼해짐',
          '3점: 보통 수준의 어조, 브랜드 느낌 부족',
          '2점: 지나치게 사무적이거나 과도하게 친근',
          '1점: 무성의한 어조 또는 불쾌한 표현 사용',
        ]),
      ],
      grades: ['우수 (22~25점)', '양호 (18~21점)', '개선필요 (14~17점)', '집중코칭 (13점 이하)'],
    );
  }

  // ==================== SCRIPT GENERATOR ====================
  static List<ConsultationScript> generateScripts(BusinessProfile profile) {
    final brand = profile.brandName.isEmpty ? profile.companyName : profile.brandName;
    final kakao = profile.kakaoChannel.isEmpty ? brand : profile.kakaoChannel;
    final scripts = <ConsultationScript>[];

    if (profile.usePhoneChannel) {
      scripts.add(ConsultationScript(id: 'SCRIPT-P1', scenarioName: '[전화] 일반 상품 문의', channel: '전화 상담', situation: 'IVR 상품 문의 선택 후 상담원 연결', steps: [
        ScriptStep(label: '인사', content: '"안녕하세요, $brand 상담원 [이름]입니다. 무엇을 도와드릴까요?"'),
        ScriptStep(label: '니즈 확인', content: '"감사합니다. 어떤 제품에 관심이 있으신지 알려주시겠어요?"'),
        ScriptStep(label: '제품 안내', content: '"말씀하신 제품에 대해 안내드리겠습니다. [제품 상세 정보 안내]"'),
        ScriptStep(label: '추가 안내', content: '"추가로 궁금하신 점이 있으시면 말씀해 주세요."'),
        ScriptStep(label: '마무리', content: '"소중한 문의 감사합니다. 좋은 하루 되세요! $brand [이름]이었습니다."'),
      ]));
      scripts.add(ConsultationScript(id: 'SCRIPT-P2', scenarioName: '[전화] 교환/반품/AS', channel: '전화 상담', situation: '교환, 반품 또는 AS 접수 콜', steps: [
        ScriptStep(label: '인사', content: '"안녕하세요, $brand [이름]입니다. 무엇을 도와드릴까요?"'),
        ScriptStep(label: '상황 파악', content: '"불편을 드려 죄송합니다. 주문번호와 제품명을 알려주시겠어요?"'),
        ScriptStep(label: '증상 확인', content: '"어떤 증상이 발생하고 있는지 자세히 말씀해 주시겠어요?"', note: 'AS의 경우'),
        ScriptStep(label: '조치 안내', content: '"해당 건은 [교환/반품/AS 수리] 절차로 진행해 드리겠습니다."'),
        ScriptStep(label: '에스컬레이션', content: '"보다 신속한 처리를 위해 담당 매니저에게 전달드리겠습니다."', note: '강한 불만 표현 시'),
        ScriptStep(label: '마무리', content: '"불편을 드린 점 다시 한번 사과드립니다. 빠르게 해결해 드리겠습니다."'),
      ]));
    }
    if (profile.useChannelTalk) {
      scripts.add(ConsultationScript(id: 'SCRIPT-CT1', scenarioName: '[채널톡] 실시간 채팅', channel: '채널톡', situation: '워크플로우에서 상담원 배정 후 실시간 응대', steps: [
        ScriptStep(label: '배정 직후', content: '"안녕하세요! $brand 상담원 [이름]입니다.\n문의 주셔서 감사합니다. 바로 확인해 드릴게요!"'),
        ScriptStep(label: '응대', content: '"확인 완료되었습니다. [답변 내용]"'),
        ScriptStep(label: '추가 안내', content: '"혹시 다른 궁금하신 점도 있으신가요?"'),
        ScriptStep(label: '클로징', content: '"도움이 되셨다면 다행이에요! 추가 문의는 언제든 편하게 남겨주세요."'),
      ]));
      scripts.add(ConsultationScript(id: 'SCRIPT-CT2', scenarioName: '[채널톡] 업무 외 자동 응답', channel: '채널톡 워크플로우', situation: '운영시간 외 문의 유입 시', steps: [
        ScriptStep(label: '자동 메시지', content: '"안녕하세요, $brand입니다.\n현재 상담 운영시간(${profile.operatingHours})이 아닙니다.\n남겨주신 문의는 다음 영업일 오전에 답변드리겠습니다."'),
        ScriptStep(label: 'FAQ 안내', content: '"자주 묻는 질문은 AI 상담으로 바로 확인 가능합니다!"'),
      ]));
    }
    if (profile.useEmailChannel) {
      scripts.add(ConsultationScript(id: 'SCRIPT-E1', scenarioName: '[이메일] 일반 문의 답변', channel: '이메일', situation: '고객 이메일 문의 수신 시 (목표: ${profile.emailResponseTarget}시간 이내)', steps: [
        ScriptStep(label: '제목', content: '[$brand] 문의하신 내용에 대한 답변입니다'),
        ScriptStep(label: '인사', content: '안녕하세요, $brand 고객센터입니다.'),
        ScriptStep(label: '본문', content: '[문의 내용 요약]\n\n[상세 답변]'),
        ScriptStep(label: '마무리', content: '추가 문의는 카카오톡 \'$kakao\' 채널로 연락해 주세요.\n\n감사합니다.\n$brand 고객센터 드림'),
      ]));
      scripts.add(ConsultationScript(id: 'SCRIPT-E2', scenarioName: '[이메일] 클레임/불만 답변', channel: '이메일', situation: '고객 불만 이메일 수신 시', steps: [
        ScriptStep(label: '제목', content: '[$brand] 불편을 드려 죄송합니다 - 조치 안내'),
        ScriptStep(label: '사과', content: '안녕하세요, $brand 고객센터입니다.\n먼저 불편을 드려 진심으로 사과드립니다.'),
        ScriptStep(label: '조치 안내', content: '해당 건에 대해 아래와 같이 조치해 드리겠습니다.\n\n1. [구체적 조치 내용]\n2. [처리 일정]'),
        ScriptStep(label: '마무리', content: '다시 한번 사과드리며, 앞으로 더 나은 서비스로 보답하겠습니다.\n\n$brand 고객센터 드림'),
      ]));
    }
    if (profile.useSnsChannel) {
      final snsNames = profile.activeSnsChannels.join('/');
      scripts.add(ConsultationScript(id: 'SCRIPT-S1', scenarioName: '[SNS] 상품 문의', channel: snsNames.isEmpty ? 'SNS' : snsNames, situation: 'SNS 채널을 통한 상품 문의 시', steps: [
        ScriptStep(label: '인사', content: '"안녕하세요! $brand입니다.\n상품 문의 주셨군요, 바로 확인해 드릴게요!"'),
        ScriptStep(label: '제품 안내', content: '"말씀하신 제품에 대해 안내드립니다.\n[제품 정보, 가격, 사양 안내]"'),
        ScriptStep(label: '클로징', content: '"더 궁금하신 점 있으시면 편하게 말씀해 주세요!"'),
      ]));
      scripts.add(ConsultationScript(id: 'SCRIPT-S2', scenarioName: '[SNS] 불만/클레임 DM', channel: snsNames.isEmpty ? 'SNS' : snsNames, situation: 'SNS DM으로 불만 접수 시', steps: [
        ScriptStep(label: '초기 대응', content: '"안녕하세요, $brand입니다.\n불편을 드려 정말 죄송합니다."'),
        ScriptStep(label: '정보 확인', content: '"주문번호와 제품명을 알려주시겠어요?"'),
        ScriptStep(label: '조치 안내', content: '"확인 완료되었습니다! [구체적 조치 방안]으로 처리해 드릴게요."'),
        ScriptStep(label: '해결 후', content: '"처리가 완료되었습니다! 다시 한번 사과드립니다."'),
      ]));
    }
    if (profile.useBoardChannel) {
      scripts.add(ConsultationScript(id: 'SCRIPT-B1', scenarioName: '[게시판] Q&A 답변', channel: '공식몰/마켓 게시판', situation: '상품 Q&A 답변 작성', steps: [
        ScriptStep(label: '답변', content: '안녕하세요, $brand입니다.\n\n[상세 답변]\n\n추가 문의는 카카오톡 \'$kakao\'로 연락 주세요!\n\n- $brand 고객센터'),
      ]));
    }
    scripts.add(ConsultationScript(id: 'SCRIPT-CMN', scenarioName: '[공통] 불만/클레임 대응', channel: '전 채널 공통', situation: '고객 불만 접수 시 (모든 채널 공통)', steps: [
      ScriptStep(label: '초기 대응', content: '"불편을 드려 정말 죄송합니다. 최선의 해결 방법을 찾아드리겠습니다."'),
      ScriptStep(label: '상황 파악', content: '"주문번호와 제품명, 발생한 문제를 자세히 알려주시겠어요?"'),
      ScriptStep(label: '조치 안내', content: '"해당 건은 [구체적 조치 방안]으로 처리해 드리겠습니다."'),
      ScriptStep(label: '해결 후', content: '"처리가 완료되었습니다. 다시 한번 사과드립니다."'),
    ]));
    scripts.add(ConsultationScript(id: 'SCRIPT-B2B', scenarioName: '[전화/이메일] B2B 제휴 문의', channel: 'B2B 전용', situation: 'B2B 협업/도매 문의 인입 시', steps: [
      ScriptStep(label: '인사', content: '"안녕하세요, $brand B2B 담당 [이름]입니다."'),
      ScriptStep(label: '정보 확인', content: '"회사명, 담당자 성함, 연락처, 관심 제품, 예상 수량을 알려주시겠어요?"'),
      ScriptStep(label: '안내', content: '"영업일 기준 24시간 이내에 맞춤 제안서를 준비해 회신드리겠습니다."'),
      ScriptStep(label: '마무리', content: '"귀한 제안 감사합니다."'),
    ]));
    return scripts;
  }

  // ==================== OPERATION DESIGN GENERATOR ====================
  static OperationDesign generateOperationDesign(BusinessProfile profile) {
    final brand = profile.brandName.isEmpty ? profile.companyName : profile.brandName;
    final company = profile.companyName;
    final agents = profile.agentCount;
    final budget = profile.monthlyBudget;
    final calls = profile.dailyCalls;
    final opHrs = profile.operatingHours;
    final channelSummary = profile.activeChannelsSummary;

    final channelOps = StringBuffer();
    channelOps.writeln('채널별 상세 운영 정책\n');
    if (profile.usePhoneChannel) {
      channelOps.writeln('[전화 상담 운영]');
      channelOps.writeln('- 대표번호: ${profile.phoneNumber.isEmpty ? "[대표번호 설정 필요]" : profile.phoneNumber}');
      channelOps.writeln('- 운영시간: ${profile.phoneOperatingHours}');
      channelOps.writeln('- IVR 자동응답 -> 상담원 연결');
      channelOps.writeln('- SLA: 80/20 (80% 콜을 20초 이내 응답)\n');
    }
    if (profile.useChannelTalk) {
      channelOps.writeln('[채널톡 운영]');
      channelOps.writeln('- 채널ID: ${profile.channelTalkId.isEmpty ? "[설정 필요]" : profile.channelTalkId}');
      channelOps.writeln('- 운영시간: ${profile.channelTalkOperatingHours}');
      channelOps.writeln('- ALF AI 자동 응답: ${profile.channelTalkAlfEnabled ? "활성화" : "비활성화"}');
      channelOps.writeln('- SLA: 초기 응답 3분 이내\n');
    }
    if (profile.useEmailChannel) {
      channelOps.writeln('[이메일 상담 운영]');
      channelOps.writeln('- 지원 이메일: ${profile.supportEmail.isEmpty ? "[설정 필요]" : profile.supportEmail}');
      channelOps.writeln('- 응답 목표: ${profile.emailResponseTarget}시간 이내\n');
    }
    if (profile.useSnsChannel) {
      channelOps.writeln('[SNS 상담 운영]');
      channelOps.writeln('- 활성 채널: ${profile.activeSnsChannels.join(", ")}');
      channelOps.writeln('- 운영시간: ${profile.snsOperatingHours}');
      channelOps.writeln('- SLA: 초기 응답 10분 이내\n');
    }
    if (profile.useBoardChannel) {
      channelOps.writeln('[게시판 상담 운영]');
      channelOps.writeln('- SLA: 일반 24시간 이내, 클레임 4시간 이내');
      channelOps.writeln('- 확인 주기: 하루 2~3회\n');
    }

    final agentSched = StringBuffer();
    agentSched.writeln('상담원 업무 분담 및 일일 운영 (${agents}명)\n');
    if (profile.agentRoles.isNotEmpty) {
      final channelNames = {'phone': '전화', 'channeltalk': '채널톡', 'email': '이메일', 'sns': 'SNS', 'board': '게시판'};
      for (final role in profile.agentRoles) {
        final chStr = role.channels.map((c) => channelNames[c] ?? c).join(', ');
        agentSched.writeln('${role.name} - ${role.title}${role.isPrimary ? " [주담당]" : ""}');
        agentSched.writeln('  담당 채널: $chStr');
        for (final r in role.responsibilities) { agentSched.writeln('  - $r'); }
        agentSched.writeln('');
      }
    }
    agentSched.writeln('[일일 타임테이블]');
    agentSched.writeln('09:00~09:30 - 일일 준비');
    agentSched.writeln('09:30~12:00 - 오전 집중 운영');
    agentSched.writeln(agents >= 2 ? '12:00~13:00 - 점심 교대 운영' : '12:00~13:00 - 점심시간 (ALF 자동 응답)');
    agentSched.writeln('13:00~15:00 - 오후 집중 운영');
    agentSched.writeln('15:00~17:00 - 오후 후반');
    agentSched.writeln('17:00~18:00 - 일일 마감');

    return OperationDesign(
      overview: '$company 고객센터 운영설계서\n\n1. 목적\n$channelSummary 채널을 ${agents}명의 상담원과 월 ${_fmt(budget)}원 이내의 예산으로 운영한다.\n\n2. 적용 범위\n- 활성 채널: $channelSummary\n- 상담원: ${agents}명\n- 일일 예상 상담: ${calls}건\n- 운영시간: $opHrs',
      systemArchitecture: '시스템 아키텍처\n\n[고객 접점 레이어]\n${profile.activeChannelsSummary}\n\n[채널 수집 레이어]\n${profile.usePhoneChannel ? "- 전화: LG U+ 클라우드고객센터 Lite\n" : ""}${profile.useChannelTalk ? "- 웹챗/SNS: 채널톡 통합 수신\n" : ""}${profile.useEmailChannel ? "- 이메일: Gmail/Outlook 연동\n" : ""}\n[상담 처리 레이어]\n- 채널톡 오퍼레이터로 통합 상담\n\n[자동화 레이어]\n${profile.channelTalkAlfEnabled ? "- ALF AI FAQ 기반 자동 응답\n" : ""}- 채널톡 워크플로우 자동 배정',
      ivrDesign: profile.usePhoneChannel ? 'IVR(자동응답) 설계\n\n[인사 멘트]\n"안녕하세요, $brand입니다."\n\n1번 - 매장 안내 (자동응답)\n2번 - 상품 문의 -> 상담원 연결\n3번 - B2B 제휴 문의\n4번 - 주문/배송/교환/AS\n0번 - 상담원 바로 연결\n\n[대기 멘트] 30초 간격, 3회 후 콜백 안내' : '전화 채널이 비활성화 상태입니다.',
      workflowDesign: '채널톡 워크플로우 설계\n\n#1. 최초 인입 분기\n#2. 예약 접수\n#3. 상품 자동 안내\n#4. 업무 외 시간 자동 응대\n#5. B2B 문의 전용 프로세스\n#6. 상담 종료 후 CSAT 수집',
      agentSchedule: agentSched.toString(),
      channelOperations: channelOps.toString(),
      slaKpi: 'SLA 및 KPI 체계\n\n[채널별 SLA]\n${profile.usePhoneChannel ? "- 전화: 80/20\n" : ""}${profile.useChannelTalk ? "- 채널톡: 3분 이내\n" : ""}${profile.useEmailChannel ? "- 이메일: ${profile.emailResponseTarget}시간 이내\n" : ""}${profile.useSnsChannel ? "- SNS: 10분 이내\n" : ""}\n[핵심 KPI]\n- 전체 응답률 90% 이상\n- CSAT 4.0/5.0 이상\n- FCR 75% 이상',
      escalationRules: '에스컬레이션 규칙\n\n1. 상담원 해결 불가 -> 기술팀 전달\n2. 환불 10만원 초과 -> 경영진 보고\n3. SNS 부정적 공개 게시물 -> 1시간 이내 대응\n4. B2B 대규모 거래 -> 경영진 배정',
      vocProcess: 'VOC 프로세스\n\n[데이터 수집]\n- 채널톡 태그 통계 + 대화 내용\n${profile.usePhoneChannel ? "- 콜 녹취 + 메모\n" : ""}${profile.useBoardChannel ? "- 게시판 Google Sheets 기록\n" : ""}\n[주간 VOC 리포트]\n시트1: 일별 로그\n시트2: 주간 요약\n시트3: 월간 인사이트',
      budget: '예산 상세 (월 ${_fmt(budget)}원)\n\n[월간 고정 비용]\n${profile.usePhoneChannel ? "- LG U+ Lite (${agents}회선): ~${_fmt(agents * 35000)}원\n" : ""}${profile.useChannelTalk ? "- 채널톡: ~27,000원\n" : ""}- 카카오 알림톡: ~10,000원\n\n합계: ~${_fmt(_calcCost(profile))}원/월\n예비비: ${_fmt(budget - _calcCost(profile))}원',
    );
  }

  static int _calcCost(BusinessProfile p) {
    int t = 10000;
    if (p.usePhoneChannel) { t += p.agentCount * 35000; t += (p.dailyCalls * 22 * 5 * 0.5).round(); }
    if (p.useChannelTalk) t += 27000;
    return t;
  }

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  // === Default Action Items for Dashboard ===
  static List<ActionItem> generateActionItems(BusinessProfile profile) {
    final items = <ActionItem>[];
    items.add(ActionItem(id: 'act-1', title: '채널톡에 FAQ 등록', description: 'ALF AI에 FAQ를 등록하여 자동 응답을 활성화하세요', documentType: 'faq', actionLabel: 'FAQ 복사'));
    items.add(ActionItem(id: 'act-2', title: '상담 스크립트 공유', description: '상담원에게 채널별 스크립트를 공유하세요', documentType: 'scripts', actionLabel: '스크립트 보기'));
    if (profile.usePhoneChannel) {
      items.add(ActionItem(id: 'act-3', title: 'IVR 멘트 녹음', description: '운영설계서의 IVR 스크립트를 기반으로 녹음하세요', documentType: 'operation', actionLabel: 'IVR 보기'));
    }
    items.add(ActionItem(id: 'act-4', title: 'QA 평가 시작', description: '주간 QA 평가를 시작하여 상담 품질을 관리하세요', documentType: 'qa', actionLabel: '평가 시작'));
    items.add(ActionItem(id: 'act-5', title: '운영설계서 검토', description: '운영설계서를 팀에게 공유하고 피드백을 받으세요', documentType: 'operation', actionLabel: '설계서 보기'));
    return items;
  }
}
