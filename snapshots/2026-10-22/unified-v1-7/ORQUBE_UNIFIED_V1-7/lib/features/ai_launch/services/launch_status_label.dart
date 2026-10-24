String launchStatusLabel(String status) {
  switch (status.trim().toLowerCase()) {
    case 'draft':
      return '비공개';
    case 'review':
      return '검토 중';
    case 'published':
      return '공개';
    case 'deploymentready':
    case 'deployment_ready':
      return '배포 준비';
    case 'deployed':
      return '배포 완료';
    case 'externalmarketready':
    case 'external_market_ready':
      return '외부시장 준비';
    case 'archived':
      return '보관';
    default:
      return status.isEmpty ? '비공개' : status;
  }
}

bool launchStatusIsActive(String status) =>
    status.trim().toLowerCase() == 'published';
