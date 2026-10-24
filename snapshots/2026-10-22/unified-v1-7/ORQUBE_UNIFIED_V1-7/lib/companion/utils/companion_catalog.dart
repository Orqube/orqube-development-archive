const companionCatalog = <String, Map<String,String>>{
"안심동행 · 역할 선택": {"en": "Safe Companion · Choose role", "ja": "安全同行 · 役割選択", "zh": "安全同行 · 选择角色", "fr": "Accompagnement · Choisir un rôle", "pt": "Companhia segura · Escolher função"},
"이용객 / 보호자": {"en": "Traveler / Guardian", "ja": "利用者 / 見守る方", "zh": "出行者 / 守护者", "fr": "Voyageur / Proche", "pt": "Viajante / Responsável"},
"이용객 · 산행·귀가 시작": {"en": "Traveler · Start trip", "ja": "利用者 · 登山・帰宅を開始", "zh": "出行者 · 开始行程", "fr": "Voyageur · Démarrer", "pt": "Viajante · Iniciar percurso"},
"보호자 · 상대 위치 보기": {"en": "Guardian · View location", "ja": "見守る方 · 位置を見る", "zh": "守护者 · 查看位置", "fr": "Proche · Voir la position", "pt": "Responsável · Ver localização"},
"이용객: 시작 준비 → 보호자 선택 → 산행·공유 시작": {"en": "Traveler: Prepare → Select guardian → Start trip and sharing", "ja": "利用者：準備 → 見守る方を選択 → 登山・共有開始", "zh": "出行者：准备 → 选择守护者 → 开始行程与共享", "fr": "Voyageur : Préparer → Choisir un proche → Démarrer et partager", "pt": "Viajante: Preparar → Escolher responsável → Iniciar e compartilhar"},
"보호자: 로그인 → 사람 연결·수락 → 상대 위치 보기": {"en": "Guardian: Sign in → Connect and accept → View location", "ja": "見守る方：ログイン → 接続・承認 → 位置を見る", "zh": "守护者：登录 → 连接并接受 → 查看位置", "fr": "Proche : Connexion → Accepter le contact → Voir la position", "pt": "Responsável: Entrar → Conectar e aceitar → Ver localização"},
"웹에서는 이 화면을 켜 두고 위치 권한과 인터넷 연결을 유지하세요. 화면 잠금·다른 탭·절전 시 위치 전송이 중단될 수 있습니다. 앱도 종료·절전 시 연속 전송을 보장하지 않습니다. 보호자는 마지막 수신 시간을 확인하세요.": {"en": "On the web, keep this screen open with location permission and internet enabled. Locking the screen, switching tabs or power saving may stop updates. Apps also cannot guarantee continuous updates when closed or restricted. Guardians must check the last update time.", "ja": "ウェブではこの画面を開き、位置情報の許可と通信を維持してください。画面ロック・タブ切替・省電力で送信が止まる場合があります。アプリも終了・省電力時の連続送信は保証しません。最後の受信時刻を確認してください。", "zh": "网页版请保持此页面开启并允许定位、保持联网。锁屏、切换标签或省电可能中断发送。应用关闭或省电时也不保证持续发送。守护者请查看最后更新时间。", "fr": "Sur le web, gardez cet écran ouvert avec la localisation et Internet activés. Le verrouillage, un autre onglet ou l’économie d’énergie peuvent interrompre les envois. L’application fermée ne garantit pas les mises à jour. Vérifiez la dernière réception.", "pt": "Na web, mantenha esta tela aberta com localização e internet ativadas. Bloqueio, outra aba ou economia de bateria podem interromper envios. O aplicativo fechado também não garante atualizações. Confira o horário da última atualização."},

  "산행 수색 참고자료": {
    "en": "Hiking search reference",
    "ja": "登山捜索の参考資料",
    "zh": "徒步搜寻参考资料",
    "fr": "Dossier de recherche randonnée",
    "pt": "Dados de referência para busca"
  },
  "마지막 기록 · 현재 위치 아님": {
    "en": "Last record · Not current location",
    "ja": "最終記録・現在地ではありません",
    "zh": "最后记录 · 并非当前位置",
    "fr": "Dernier relevé · Pas la position actuelle",
    "pt": "Último registro · Não é a posição atual"
  },
  "산행 시작": {
    "en": "Hike started",
    "ja": "登山開始",
    "zh": "徒步开始",
    "fr": "Début de randonnée",
    "pt": "Início da trilha"
  },
  "귀환 예정": {
    "en": "Planned return",
    "ja": "帰還予定",
    "zh": "预计返回",
    "fr": "Retour prévu",
    "pt": "Retorno previsto"
  },
  "마지막 GPS 기록": {
    "en": "Last GPS observation",
    "ja": "最終GPS記録",
    "zh": "最后GPS记录",
    "fr": "Dernier relevé GPS",
    "pt": "Último registro GPS"
  },
  "마지막 서버 수신": {
    "en": "Last server receipt",
    "ja": "最終サーバー受信",
    "zh": "服务器最后接收",
    "fr": "Dernière réception serveur",
    "pt": "Último recebimento no servidor"
  },
  "보호자 조회 기한": {
    "en": "Contact access expires",
    "ja": "保護者の閲覧期限",
    "zh": "联系人查看期限",
    "fr": "Expiration de l’accès des proches",
    "pt": "Prazo de acesso do contato"
  },
  "경로 파일 내보내기": {
    "en": "Export route file",
    "ja": "経路ファイルを書き出す",
    "zh": "导出路线文件",
    "fr": "Exporter le parcours",
    "pt": "Exportar arquivo da rota"
  },
  "수색 요약 복사": {
    "en": "Copy search summary",
    "ja": "捜索用の要約をコピー",
    "zh": "复制搜寻摘要",
    "fr": "Copier le résumé de recherche",
    "pt": "Copiar resumo para busca"
  },
  "서버 반영 재시도": {
    "en": "Retry server sync",
    "ja": "サーバー同期を再試行",
    "zh": "重试服务器同步",
    "fr": "Réessayer la synchronisation",
    "pt": "Tentar sincronizar novamente"
  },
  "기기 기록과 서버 자료 삭제": {
    "en": "Delete device and server records",
    "ja": "端末とサーバーの記録を削除",
    "zh": "删除设备和服务器记录",
    "fr": "Supprimer les données locales et serveur",
    "pt": "Excluir registros locais e do servidor"
  },
  "저장된 산행 기록": {
    "en": "Saved hiking record",
    "ja": "保存した登山記録",
    "zh": "已保存的徒步记录",
    "fr": "Randonnée enregistrée",
    "pt": "Registro de trilha salvo"
  },
  "새 산행 시작": {
    "en": "Start a new hike",
    "ja": "新しい登山を開始",
    "zh": "开始新徒步",
    "fr": "Nouvelle randonnée",
    "pt": "Iniciar nova trilha"
  },
  "기록 이어가기": {
    "en": "Resume recording",
    "ja": "記録を再開",
    "zh": "继续记录",
    "fr": "Reprendre l’enregistrement",
    "pt": "Retomar registro"
  },
  "통신두절 대비 자료 공유": {
    "en": "Share records for connection loss",
    "ja": "通信途絶に備えて記録を共有",
    "zh": "共享失联备用资料",
    "fr": "Partager en cas de perte de connexion",
    "pt": "Compartilhar para perda de conexão"
  },
  "실시간 위치만 공유": {
    "en": "Share live location only",
    "ja": "現在地のみ共有",
    "zh": "仅共享实时位置",
    "fr": "Partager seulement la position en direct",
    "pt": "Compartilhar apenas localização ao vivo"
  },
  "동의하고 자료 공유": {
    "en": "Consent and share records",
    "ja": "同意して記録を共有",
    "zh": "同意并共享资料",
    "fr": "Accepter et partager les données",
    "pt": "Concordar e compartilhar dados"
  },
  "오프라인 기록 · 수색 참고자료": {
    "en": "Offline record · Search reference",
    "ja": "オフライン記録・捜索参考資料",
    "zh": "离线记录 · 搜寻参考资料",
    "fr": "Relevé hors ligne · Aide à la recherche",
    "pt": "Registro offline · Referência para busca"
  },
  "저장된 기록과 내보내기": {
    "en": "Saved records and export",
    "ja": "保存記録と書き出し",
    "zh": "已存记录与导出",
    "fr": "Données enregistrées et export",
    "pt": "Registros salvos e exportação"
  },
  "마지막 산행 기록 · 수색 참고자료": {
    "en": "Last hiking record · Search reference",
    "ja": "最終登山記録・捜索参考資料",
    "zh": "最后徒步记录 · 搜寻资料",
    "fr": "Dernière randonnée · Aide à la recherche",
    "pt": "Última trilha · Referência para busca"
  },
  "서버 반영 완료": {
    "en": "Server sync complete",
    "ja": "サーバー同期完了",
    "zh": "服务器同步完成",
    "fr": "Synchronisation terminée",
    "pt": "Sincronização concluída"
  },
  "서버 전송 대기 · 연결 복구 후 재시도": {
    "en": "Upload pending · Retry after reconnection",
    "ja": "送信待ち・接続回復後に再試行",
    "zh": "等待上传 · 恢复连接后重试",
    "fr": "Envoi en attente · Réessai après reconnexion",
    "pt": "Envio pendente · Tentar após reconexão"
  },
  "기기 저장 실패 · 저장 공간을 확인하세요.": {
    "en": "Device save failed · Check storage space.",
    "ja": "端末への保存失敗・空き容量を確認してください。",
    "zh": "设备保存失败 · 请检查存储空间。",
    "fr": "Échec local · Vérifiez l’espace disponible.",
    "pt": "Falha ao salvar · Verifique o espaço livre."
  },
  "저장된 자료 · 서버 연결 확인 필요": {
    "en": "Cached records · Check server connection",
    "ja": "保存済み資料・サーバー接続を確認",
    "zh": "缓存资料 · 请检查服务器连接",
    "fr": "Données en cache · Connexion à vérifier",
    "pt": "Dados em cache · Verifique a conexão"
  },
  "통신두절 이후의 현재 위치는 알 수 없습니다. 아래 시간과 좌표는 마지막 GPS 기록입니다. 자동 구조 요청은 전송하지 않습니다.": {
    "en": "The current position after connection loss is unknown. These coordinates and times are recorded GPS observations. No automatic rescue request is sent.",
    "ja": "通信途絶後の現在地は不明です。時刻と座標は最後のGPS記録です。救助要請は自動送信しません。",
    "zh": "断网后的当前位置未知。以下时间与坐标为最后GPS记录。不会自动发送救援请求。",
    "fr": "La position après la coupure est inconnue. Ces coordonnées et heures sont des relevés GPS. Aucun secours n’est demandé automatiquement.",
    "pt": "A posição após a perda de conexão é desconhecida. Horários e coordenadas são registros GPS. Nenhum pedido de resgate é enviado automaticamente."
  },
  "내보낸 파일은 앱에서 회수할 수 없습니다. 필요한 수색 담당자에게만 직접 전달하세요.": {
    "en": "Exported files cannot be recalled by the app. Share directly only with necessary search personnel.",
    "ja": "書き出したファイルはアプリから回収できません。必要な捜索担当者にのみ直接渡してください。",
    "zh": "应用无法收回已导出的文件。请仅直接交给必要的搜寻人员。",
    "fr": "L’application ne peut pas récupérer les fichiers exportés. Transmettez-les uniquement aux intervenants nécessaires.",
    "pt": "O app não pode recuperar arquivos exportados. Envie apenas aos responsáveis necessários pela busca."
  },
  "기기에 경로를 저장하고 동의한 자료는 통신 복구 후 재전송합니다. 앱 강제 종료 중에는 새 위치가 기록되지 않습니다.": {
    "en": "Routes are saved on the device. Consented records retry after reconnection. No new GPS points are recorded while the app is force-closed.",
    "ja": "経路を端末に保存し、同意済み資料は接続回復後に再送します。強制終了中は新しい位置を記録しません。",
    "zh": "路线保存在设备上，经同意的资料在恢复连接后重传。强制关闭期间不会记录新位置。",
    "fr": "Le parcours est enregistré localement. Les données autorisées sont renvoyées après reconnexion. Aucun point n’est enregistré si l’application est arrêtée de force.",
    "pt": "Rotas são salvas no aparelho. Dados consentidos são reenviados após reconexão. O app encerrado à força não registra novos pontos."
  },
  "승인한 보호자가 마지막 GPS 위치·기록 시각·산행 경로·귀환 계획을 서버 수신 후 최대 24시간 조회하도록 동의하시나요? 실시간 공유가 만료되어도 이 자료는 남습니다. 공유 중지·산행 종료 시 삭제를 요청합니다. 오프라인이면 삭제 반영이 지연되며 기존 조회는 보관 기한까지 가능할 수 있습니다. 자료를 내보내면 앱에서 회수할 수 없습니다.": {
    "en": "Allow approved contacts to view the last GPS observation, its time, hiking route and return plan for up to 24 hours after server receipt? These records remain after live sharing expires. Stopping sharing or ending the hike requests deletion. Offline deletion may be delayed and access may remain until expiry. Exported files cannot be recalled.",
    "ja": "承認した保護者が最終GPS位置・時刻・経路・帰還計画をサーバー受信後最大24時間閲覧することに同意しますか？現在地共有が失効しても資料は残ります。共有停止・登山終了時に削除を要求します。オフラインでは削除が遅れ、期限まで閲覧できる場合があります。書き出したファイルは回収できません。",
    "zh": "是否允许已批准的联系人在服务器接收后最多24小时内查看最后GPS位置、时间、路线和返回计划？实时共享到期后资料仍保留。停止共享或结束徒步时请求删除。离线时删除可能延迟，查看权限可能持续至到期。导出文件无法收回。",
    "fr": "Autoriser les proches approuvés à consulter le dernier relevé GPS, son heure, le parcours et le retour prévu pendant 24 h maximum après réception ? Ces données restent après expiration du direct. L’arrêt du partage ou de la randonnée demande leur suppression. Hors ligne, elle peut être retardée et l’accès rester ouvert jusqu’à expiration. Les fichiers exportés ne peuvent pas être récupérés.",
    "pt": "Permitir que contatos aprovados vejam o último GPS, horário, rota e retorno previsto por até 24 horas após o recebimento? Os dados permanecem após expirar o compartilhamento ao vivo. Parar o compartilhamento ou encerrar a trilha solicita exclusão. Offline, a exclusão pode atrasar e o acesso continuar até expirar. Arquivos exportados não podem ser recuperados."
  },
  "안전산행": {
    "en": "Safe hiking",
    "ja": "安全登山",
    "zh": "安全徒步",
    "fr": "Randonnée sûre",
    "pt": "Trilha segura"
  },
  "안심귀가": {
    "en": "Safe return",
    "ja": "安心帰宅",
    "zh": "安全回家",
    "fr": "Retour sécurisé",
    "pt": "Volta segura"
  },
  "안심동행": {
    "en": "Safe Companion",
    "ja": "安心同行",
    "zh": "安心同行",
    "fr": "Compagnon sécurité",
    "pt": "Companhia segura"
  },
  "가족·친구 위치 확인": {
    "en": "Family & friends location",
    "ja": "家族・友人の位置確認",
    "zh": "家人朋友位置",
    "fr": "Position des proches",
    "pt": "Localização de familiares e amigos"
  },
  "로그인 · 내 계정": {
    "en": "Sign in · My account",
    "ja": "ログイン・マイアカウント",
    "zh": "登录·我的账户",
    "fr": "Connexion · Mon compte",
    "pt": "Entrar · Minha conta"
  },
  "통합 사용설명서": {
    "en": "User guide",
    "ja": "総合ガイド",
    "zh": "使用指南",
    "fr": "Guide d’utilisation",
    "pt": "Guia de uso"
  },
  "산행 경로와 귀환 계획": {
    "en": "Hiking route and return plan",
    "ja": "登山ルートと帰還計画",
    "zh": "徒步路线与返回计划",
    "fr": "Parcours et retour prévu",
    "pt": "Percurso e retorno previsto"
  },
  "목적지와 귀가 경로 기록": {
    "en": "Destination and return route",
    "ja": "目的地と帰宅ルート記録",
    "zh": "目的地与回家路线",
    "fr": "Destination et trajet de retour",
    "pt": "Destino e percurso de volta"
  },
  "보호자 연결 · 승인한 사람만 위치 확인": {
    "en": "Trusted contacts · Approved viewers only",
    "ja": "保護者連携・承認した相手のみ閲覧",
    "zh": "联系人连接·仅已批准者可查看",
    "fr": "Contacts de confiance · Accès autorisé",
    "pt": "Contatos de confiança · Somente autorizados"
  },
  "오르큐브 계정으로 이용": {
    "en": "Use your ORQUBE account",
    "ja": "ORQUBEアカウントで利用",
    "zh": "使用ORQUBE账户",
    "fr": "Avec votre compte ORQUBE",
    "pt": "Use sua conta ORQUBE"
  },
  "산행 · 귀가 · 가족과 친구 위치 공유 안내": {
    "en": "Hiking, return and location sharing guide",
    "ja": "登山・帰宅・位置共有ガイド",
    "zh": "徒步、回家与位置共享指南",
    "fr": "Guide randonnée, retour et partage",
    "pt": "Guia de trilha, volta e localização"
  },
  "떠나는 순간부터\n안전하게 돌아올 때까지": {
    "en": "From departure\nto a safe return",
    "ja": "出発から\n無事に帰るまで",
    "zh": "从出发\n到平安归来",
    "fr": "Du départ\nau retour en sécurité",
    "pt": "Da partida\na uma volta segura"
  },
  "나의 동의로 시작하는 위치 공유\n안전산행 · 안심귀가 · 보호자 연결": {
    "en": "Location sharing with your consent\nHiking · Return · Trusted contacts",
    "ja": "自分の同意で始める位置共有\n登山・帰宅・保護者連携",
    "zh": "经本人同意的位置共享\n徒步·回家·联系人连接",
    "fr": "Partage avec votre consentement\nRandonnée · Retour · Proches",
    "pt": "Compartilhe com consentimento\nTrilha · Volta · Contatos"
  },
  "로그인": {
    "en": "Sign in",
    "ja": "ログイン",
    "zh": "登录",
    "fr": "Connexion",
    "pt": "Entrar"
  },
  "로그아웃": {
    "en": "Sign out",
    "ja": "ログアウト",
    "zh": "退出登录",
    "fr": "Déconnexion",
    "pt": "Sair"
  },
  "회원가입": {
    "en": "Create account",
    "ja": "アカウント作成",
    "zh": "注册",
    "fr": "Créer un compte",
    "pt": "Criar conta"
  },
  "이메일": {
    "en": "Email",
    "ja": "メール",
    "zh": "电子邮箱",
    "fr": "E-mail",
    "pt": "E-mail"
  },
  "비밀번호": {
    "en": "Password",
    "ja": "パスワード",
    "zh": "密码",
    "fr": "Mot de passe",
    "pt": "Senha"
  },
  "취소": {
    "en": "Cancel",
    "ja": "キャンセル",
    "zh": "取消",
    "fr": "Annuler",
    "pt": "Cancelar"
  },
  "확인": {
    "en": "Confirm",
    "ja": "確認",
    "zh": "确认",
    "fr": "Confirmer",
    "pt": "Confirmar"
  },
  "승인": {
    "en": "Approve",
    "ja": "承認",
    "zh": "批准",
    "fr": "Autoriser",
    "pt": "Aprovar"
  },
  "해제": {
    "en": "Revoke",
    "ja": "解除",
    "zh": "解除",
    "fr": "Révoquer",
    "pt": "Revogar"
  },
  "내 계정": {
    "en": "My account",
    "ja": "マイアカウント",
    "zh": "我的账户",
    "fr": "Mon compte",
    "pt": "Minha conta"
  },
  "이메일 인증 완료": {
    "en": "Email verified",
    "ja": "メール認証済み",
    "zh": "邮箱已验证",
    "fr": "E-mail vérifié",
    "pt": "E-mail verificado"
  },
  "이메일 인증이 필요합니다.": {
    "en": "Email verification is required.",
    "ja": "メール認証が必要です。",
    "zh": "需要验证邮箱。",
    "fr": "Vérifiez votre e-mail.",
    "pt": "Verifique seu e-mail."
  },
  "인증 이메일 다시 보내기": {
    "en": "Resend verification email",
    "ja": "認証メールを再送",
    "zh": "重新发送验证邮件",
    "fr": "Renvoyer l’e-mail",
    "pt": "Reenviar e-mail de verificação"
  },
  "인증 상태 새로고침": {
    "en": "Refresh verification",
    "ja": "認証状態を更新",
    "zh": "刷新验证状态",
    "fr": "Actualiser la vérification",
    "pt": "Atualizar verificação"
  },
  "이전 화면으로 돌아가기": {
    "en": "Back to previous screen",
    "ja": "前の画面に戻る",
    "zh": "返回上一页",
    "fr": "Revenir à l’écran précédent",
    "pt": "Voltar à tela anterior"
  },
  "처리 중": {
    "en": "Processing",
    "ja": "処理中",
    "zh": "处理中",
    "fr": "Traitement",
    "pt": "Processando"
  },
  "로그인되었습니다.": {
    "en": "Signed in.",
    "ja": "ログインしました。",
    "zh": "已登录。",
    "fr": "Connexion réussie.",
    "pt": "Login efetuado."
  },
  "인증 메일을 보냈습니다.": {
    "en": "Verification email sent.",
    "ja": "認証メールを送信しました。",
    "zh": "验证邮件已发送。",
    "fr": "E-mail envoyé.",
    "pt": "E-mail enviado."
  },
  "이메일 형식을 확인하세요.": {
    "en": "Check the email address.",
    "ja": "メールアドレスを確認してください。",
    "zh": "请检查邮箱格式。",
    "fr": "Vérifiez l’adresse e-mail.",
    "pt": "Confira o endereço de e-mail."
  },
  "더 강한 비밀번호를 사용하세요.": {
    "en": "Use a stronger password.",
    "ja": "より強いパスワードを使用してください。",
    "zh": "请使用更强的密码。",
    "fr": "Utilisez un mot de passe plus sûr.",
    "pt": "Use uma senha mais forte."
  },
  "인터넷 연결을 확인하세요.": {
    "en": "Check your internet connection.",
    "ja": "インターネット接続を確認してください。",
    "zh": "请检查网络连接。",
    "fr": "Vérifiez votre connexion Internet.",
    "pt": "Verifique sua conexão à internet."
  },
  "보호자": {
    "en": "Trusted contact",
    "ja": "保護者",
    "zh": "可信联系人",
    "fr": "Contact de confiance",
    "pt": "Contato de confiança"
  },
  "보호자 연결": {
    "en": "Trusted contacts",
    "ja": "保護者連携",
    "zh": "联系人连接",
    "fr": "Contacts de confiance",
    "pt": "Contatos de confiança"
  },
  "로그인 후 이용": {
    "en": "Sign in to continue",
    "ja": "ログインして利用",
    "zh": "登录后使用",
    "fr": "Connectez-vous pour continuer",
    "pt": "Entre para continuar"
  },
  "01  나의 연결 카드": {
    "en": "01  My connection card",
    "ja": "01  自分の接続カード",
    "zh": "01  我的连接卡",
    "fr": "01  Ma carte de connexion",
    "pt": "01  Meu cartão de conexão"
  },
  "내 연결 ID (지정 보호자에게만 전달)": {
    "en": "My connection ID (share only with trusted contacts)",
    "ja": "自分の接続ID（指定相手のみに共有）",
    "zh": "我的连接ID（仅告知可信联系人）",
    "fr": "Mon identifiant (à partager avec un proche)",
    "pt": "Meu ID (compartilhe apenas com contatos de confiança)"
  },
  "내 ID 복사": {
    "en": "Copy my ID",
    "ja": "自分のIDをコピー",
    "zh": "复制我的ID",
    "fr": "Copier mon identifiant",
    "pt": "Copiar meu ID"
  },
  "02  상대방과 연결": {
    "en": "02  Connect with someone",
    "ja": "02  相手と接続",
    "zh": "02  连接对方",
    "fr": "02  Se connecter à un proche",
    "pt": "02  Conectar outra pessoa"
  },
  "위치를 공유할 상대방의 연결 ID": {
    "en": "Connection ID of the person sharing location",
    "ja": "位置を共有する相手の接続ID",
    "zh": "共享位置者的连接ID",
    "fr": "Identifiant de la personne à suivre",
    "pt": "ID da pessoa que compartilha a localização"
  },
  "상대방에게 연결 요청": {
    "en": "Send connection request",
    "ja": "接続リクエストを送信",
    "zh": "发送连接请求",
    "fr": "Envoyer une demande",
    "pt": "Enviar solicitação"
  },
  "승인 후 상대 위치 확인": {
    "en": "View location after approval",
    "ja": "承認後に相手の位置を確認",
    "zh": "批准后查看位置",
    "fr": "Voir la position après autorisation",
    "pt": "Ver localização após aprovação"
  },
  "나에게 들어온 연결 요청": {
    "en": "Incoming requests",
    "ja": "受信した接続リクエスト",
    "zh": "收到的连接请求",
    "fr": "Demandes reçues",
    "pt": "Solicitações recebidas"
  },
  "승인된 보호자 · 접근 해제": {
    "en": "Approved contacts · Revoke access",
    "ja": "承認済みの相手・アクセス解除",
    "zh": "已批准联系人·撤销权限",
    "fr": "Contacts autorisés · Révoquer",
    "pt": "Contatos aprovados · Revogar acesso"
  },
  "이 보호자에게 내 위치를 공유할까요?": {
    "en": "Allow this contact to view your location?",
    "ja": "この相手に位置共有を許可しますか？",
    "zh": "允许此联系人查看您的位置吗？",
    "fr": "Autoriser ce contact à voir votre position ?",
    "pt": "Permitir que este contato veja sua localização?"
  },
  "상대방이 아직 공유를 시작하지 않았습니다.": {
    "en": "The other person has not started sharing yet.",
    "ja": "相手はまだ共有を開始していません。",
    "zh": "对方尚未开始共享。",
    "fr": "Le partage n’a pas encore commencé.",
    "pt": "A outra pessoa ainda não iniciou o compartilhamento."
  },
  "상대방의 위치 공유가 꺼져 있습니다.": {
    "en": "The other person’s location sharing is off.",
    "ja": "相手の位置共有は停止中です。",
    "zh": "对方的位置共享已关闭。",
    "fr": "Le partage de position est désactivé.",
    "pt": "O compartilhamento da outra pessoa está desativado."
  },
  "이동 경로": {
    "en": "Travel route",
    "ja": "移動ルート",
    "zh": "移动路线",
    "fr": "Trajet",
    "pt": "Percurso"
  },
  "마지막 서버 수신:": {
    "en": "Last server update:",
    "ja": "最終サーバー更新：",
    "zh": "服务器最后更新：",
    "fr": "Dernière mise à jour :",
    "pt": "Última atualização:"
  },
  "최근 경로 최대 500개 지점": {
    "en": "Up to 500 recent route points",
    "ja": "直近ルート最大500地点",
    "zh": "最近路线最多500个点",
    "fr": "Jusqu’à 500 points récents",
    "pt": "Até 500 pontos recentes"
  },
  "서로의 안심을 잇다": {
    "en": "Stay connected, feel reassured",
    "ja": "つながる安心",
    "zh": "连接彼此的安心",
    "fr": "Restez proches, rassurés",
    "pt": "Conectados com tranquilidade"
  },
  "승인한 사람과 함께 보는 현재 위치와 이동 경로": {
    "en": "Current location and route for approved contacts",
    "ja": "承認した相手と現在位置・移動ルートを共有",
    "zh": "与已批准联系人共享当前位置和路线",
    "fr": "Position et trajet pour vos proches autorisés",
    "pt": "Localização e percurso para contatos aprovados"
  },
  "연결되면 이곳에 지도가 표시됩니다": {
    "en": "Your shared map will appear here",
    "ja": "接続するとここに地図が表示されます",
    "zh": "连接后将在此显示地图",
    "fr": "La carte s’affichera ici",
    "pt": "O mapa compartilhado aparecerá aqui"
  },
  "연결 요청 → 상대 승인 → 이동·공유 시작 → 위치 확인": {
    "en": "Request → Approval → Start trip and sharing → View",
    "ja": "リクエスト → 承認 → 移動・共有開始 → 確認",
    "zh": "请求→批准→开始移动及共享→查看",
    "fr": "Demande → Accord → Départ et partage → Carte",
    "pt": "Solicitar → Aprovar → Iniciar e compartilhar → Ver"
  },
  "● 초록: 최근 경로 시작점   ━ 파랑: 이동 경로   📍 현재 위치": {
    "en": "● Green: route start   ━ Blue: route   📍 Current location",
    "ja": "● 緑：開始点   ━ 青：ルート   📍 現在位置",
    "zh": "● 绿：路线起点   ━ 蓝：路线   📍 当前位置",
    "fr": "● Vert : départ   ━ Bleu : trajet   📍 Position actuelle",
    "pt": "● Verde: início   ━ Azul: percurso   📍 Localização atual"
  },
  "안전산행 · 안심귀가 · 가족과 친구": {
    "en": "Hiking · Safe return · Family and friends",
    "ja": "登山・帰宅・家族と友人",
    "zh": "徒步·回家·家人朋友",
    "fr": "Randonnée · Retour · Proches",
    "pt": "Trilha · Volta · Familiares e amigos"
  },
  "시작부터 위치 공유 종료까지": {
    "en": "From getting started to ending location sharing",
    "ja": "開始から位置共有の終了まで",
    "zh": "从开始到结束位置共享",
    "fr": "Du départ à la fin du partage",
    "pt": "Do início ao fim do compartilhamento"
  },
  "산에서도, 귀갓길에서도\n마음 편히 함께하세요.": {
    "en": "On the trail or on your way home,\nstay connected with peace of mind.",
    "ja": "山でも帰り道でも、\n安心して一緒に。",
    "zh": "无论山间还是归途，\n安心相伴。",
    "fr": "En randonnée ou sur le chemin du retour,\nrestez sereins.",
    "pt": "Na trilha ou a caminho de casa,\nfique conectado com tranquilidade."
  },
  "오늘도 안전하게,\n소중한 사람과 함께.": {
    "en": "Stay safe today,\nwith those you care about.",
    "ja": "今日も安全に、\n大切な人と一緒に。",
    "zh": "今天也平安，\n与重要的人同行。",
    "fr": "En sécurité aujourd’hui,\navec vos proches.",
    "pt": "Em segurança hoje,\ncom quem você ama."
  },
  "산행 기록": {
    "en": "Hiking record",
    "ja": "登山記録",
    "zh": "徒步记录",
    "fr": "Historique de randonnée",
    "pt": "Registro de trilha"
  },
  "위치 공유": {
    "en": "Location sharing",
    "ja": "位置共有",
    "zh": "位置共享",
    "fr": "Partage de position",
    "pt": "Compartilhar localização"
  },
  "현재 위치": {
    "en": "Current location",
    "ja": "現在位置",
    "zh": "当前位置",
    "fr": "Position actuelle",
    "pt": "Localização atual"
  },
  "목적지 선택": {
    "en": "Choose destination",
    "ja": "目的地を選択",
    "zh": "选择目的地",
    "fr": "Choisir une destination",
    "pt": "Escolher destino"
  },
  "이동 시작": {
    "en": "Start trip",
    "ja": "移動開始",
    "zh": "开始移动",
    "fr": "Démarrer le trajet",
    "pt": "Iniciar percurso"
  },
  "보호자 공유": {
    "en": "Share with contacts",
    "ja": "保護者と共有",
    "zh": "与联系人共享",
    "fr": "Partager avec les proches",
    "pt": "Compartilhar com contatos"
  },
  "종료": {
    "en": "End",
    "ja": "終了",
    "zh": "结束",
    "fr": "Terminer",
    "pt": "Encerrar"
  },
  "귀가 완료 · 종료": {
    "en": "Arrived home · End",
    "ja": "帰宅完了・終了",
    "zh": "已到家·结束",
    "fr": "Arrivé · Terminer",
    "pt": "Cheguei · Encerrar"
  },
  "안전하게 귀가할 준비가 되셨나요?": {
    "en": "Ready for a safe trip home?",
    "ja": "安全に帰宅する準備はできましたか？",
    "zh": "准备好安全回家了吗？",
    "fr": "Prêt pour rentrer en sécurité ?",
    "pt": "Pronto para voltar em segurança?"
  },
  "산행을 시작할 준비가 되셨나요?": {
    "en": "Ready to start your hike?",
    "ja": "登山を始める準備はできましたか？",
    "zh": "准备开始徒步了吗？",
    "fr": "Prêt pour la randonnée ?",
    "pt": "Pronto para iniciar a trilha?"
  },
  "공유 종료": {
    "en": "Stop sharing",
    "ja": "共有を停止",
    "zh": "停止共享",
    "fr": "Arrêter le partage",
    "pt": "Parar compartilhamento"
  },
  "이동 종료까지 보호자 위치 공유": {
    "en": "Share location until trip ends",
    "ja": "移動終了まで位置を共有",
    "zh": "共享位置直到行程结束",
    "fr": "Partager jusqu’à la fin du trajet",
    "pt": "Compartilhar até encerrar o percurso"
  },
  "나의 안심동행 계정": {
    "en": "My Safe Companion account",
    "ja": "安心同行アカウント",
    "zh": "我的安心同行账户",
    "fr": "Mon compte Safe Companion",
    "pt": "Minha conta Safe Companion"
  },
  "다시 만나 반갑습니다": {
    "en": "Welcome back",
    "ja": "おかえりなさい",
    "zh": "欢迎回来",
    "fr": "Heureux de vous revoir",
    "pt": "Bem-vindo de volta"
  },
  "오르큐브와 함께 사용할 계정을 만드세요.": {
    "en": "Create an account for ORQUBE.",
    "ja": "ORQUBE用アカウントを作成してください。",
    "zh": "创建ORQUBE账户。",
    "fr": "Créez un compte ORQUBE.",
    "pt": "Crie uma conta ORQUBE."
  },
  "기존 오르큐브 이메일 계정으로 로그인하세요.": {
    "en": "Sign in with your existing ORQUBE email account.",
    "ja": "既存のORQUBEメールアカウントでログインしてください。",
    "zh": "使用现有ORQUBE邮箱账户登录。",
    "fr": "Connectez-vous avec votre compte ORQUBE.",
    "pt": "Entre com sua conta de e-mail ORQUBE."
  },
  "계정과 개인정보를 한곳에서 관리하세요.": {
    "en": "Manage your account and personal information.",
    "ja": "アカウントと個人情報を管理します。",
    "zh": "管理账户和个人信息。",
    "fr": "Gérez votre compte et vos données personnelles.",
    "pt": "Gerencie sua conta e seus dados pessoais."
  },
  "로그인한 이메일": {
    "en": "Signed-in email",
    "ja": "ログイン中のメール",
    "zh": "已登录邮箱",
    "fr": "E-mail connecté",
    "pt": "E-mail conectado"
  },
  "비밀번호 보기": {
    "en": "Show password",
    "ja": "パスワードを表示",
    "zh": "显示密码",
    "fr": "Afficher le mot de passe",
    "pt": "Mostrar senha"
  },
  "비밀번호 숨기기": {
    "en": "Hide password",
    "ja": "パスワードを隠す",
    "zh": "隐藏密码",
    "fr": "Masquer le mot de passe",
    "pt": "Ocultar senha"
  },
  "8자 이상 입력해주세요": {
    "en": "Enter at least 8 characters",
    "ja": "8文字以上入力してください",
    "zh": "请输入至少8个字符",
    "fr": "Saisissez au moins 8 caractères",
    "pt": "Digite pelo menos 8 caracteres"
  },
  "비밀번호를 입력해주세요": {
    "en": "Enter your password",
    "ja": "パスワードを入力してください",
    "zh": "请输入密码",
    "fr": "Saisissez votre mot de passe",
    "pt": "Digite sua senha"
  },
  "이메일 주소를 확인해주세요.": {
    "en": "Check your email address.",
    "ja": "メールアドレスを確認してください。",
    "zh": "请检查邮箱地址。",
    "fr": "Vérifiez votre adresse e-mail.",
    "pt": "Confira seu endereço de e-mail."
  },
  "회원가입 · 인증 메일 받기": {
    "en": "Create account · Get verification email",
    "ja": "登録・認証メールを受け取る",
    "zh": "注册·获取验证邮件",
    "fr": "S’inscrire · Recevoir l’e-mail",
    "pt": "Criar conta · Receber verificação"
  },
  "비밀번호를 잊으셨나요?": {
    "en": "Forgot your password?",
    "ja": "パスワードをお忘れですか？",
    "zh": "忘记密码？",
    "fr": "Mot de passe oublié ?",
    "pt": "Esqueceu a senha?"
  },
  "개인정보 처리 안내를 확인했습니다.": {
    "en": "I have read the privacy information.",
    "ja": "個人情報の取扱案内を確認しました。",
    "zh": "我已阅读隐私说明。",
    "fr": "J’ai lu les informations de confidentialité.",
    "pt": "Li as informações de privacidade."
  },
  "첫 실행 안내의 처리 내용을 확인하고 회원가입에 동의합니다.": {
    "en": "I have read the first-use privacy notice and agree to create an account.",
    "ja": "初回案内の取扱内容を確認し、登録に同意します。",
    "zh": "我已阅读首次使用隐私说明并同意注册。",
    "fr": "J’ai lu l’avis de confidentialité et accepte de créer un compte.",
    "pt": "Li o aviso inicial de privacidade e concordo em criar uma conta."
  },
  "로그인 상태는 이 기기에 유지됩니다.\n공용 기기에서는 이용 후 로그아웃해주세요.": {
    "en": "You stay signed in on this device.\nSign out after using a shared device.",
    "ja": "この端末でログインを保持します。\n共用端末では利用後にログアウトしてください。",
    "zh": "此设备将保持登录。\n使用公共设备后请退出。",
    "fr": "La connexion reste active sur cet appareil.\nDéconnectez-vous sur un appareil partagé.",
    "pt": "O login permanece neste dispositivo.\nSaia após usar um dispositivo compartilhado."
  },
  "기록 삭제 · 회원탈퇴": {
    "en": "Delete records · Delete account",
    "ja": "記録削除・退会",
    "zh": "删除记录·注销账户",
    "fr": "Supprimer les données · Le compte",
    "pt": "Excluir registros · Excluir conta"
  },
  "기록 삭제": {
    "en": "Delete records",
    "ja": "記録を削除",
    "zh": "删除记录",
    "fr": "Supprimer les données",
    "pt": "Excluir registros"
  },
  "회원탈퇴": {
    "en": "Delete account",
    "ja": "退会",
    "zh": "注销账户",
    "fr": "Supprimer le compte",
    "pt": "Excluir conta"
  },
  "산행 기록 삭제": {
    "en": "Delete trip records",
    "ja": "移動記録を削除",
    "zh": "删除行程记录",
    "fr": "Supprimer les trajets",
    "pt": "Excluir percursos"
  },
  "ORQUBE 회원탈퇴": {
    "en": "Delete ORQUBE account",
    "ja": "ORQUBE退会",
    "zh": "注销ORQUBE账户",
    "fr": "Supprimer le compte ORQUBE",
    "pt": "Excluir conta ORQUBE"
  },
  "확인 후 진행하는 계정 관리 항목": {
    "en": "Account actions requiring confirmation",
    "ja": "確認が必要なアカウント操作",
    "zh": "需确认的账户操作",
    "fr": "Actions nécessitant confirmation",
    "pt": "Ações que exigem confirmação"
  },
  "준비하고, 기록하고, 안전하게 돌아오세요.": {
    "en": "Prepare, record and return safely.",
    "ja": "準備して記録し、安全に帰りましょう。",
    "zh": "做好准备，记录行程，平安归来。",
    "fr": "Préparez, enregistrez et rentrez en sécurité.",
    "pt": "Prepare-se, registre e volte em segurança."
  },
  "상세 사용설명서와 데이터 처리 안내": {
    "en": "User guide and privacy information",
    "ja": "詳細ガイドとデータ取扱案内",
    "zh": "详细指南与数据处理说明",
    "fr": "Guide et traitement des données",
    "pt": "Guia e tratamento de dados"
  },
  "개인정보·위치 사용 방식과 지원 범위를 확인했습니다.": {
    "en": "I have read how personal data and location are used and the service limits.",
    "ja": "個人情報・位置情報の利用方法と対応範囲を確認しました。",
    "zh": "我已了解个人信息、位置用途及服务范围。",
    "fr": "J’ai lu l’usage des données, de la position et les limites du service.",
    "pt": "Li o uso de dados, localização e os limites do serviço."
  },
  "안심동행 시작하기": {
    "en": "Start Safe Companion",
    "ja": "安心同行を始める",
    "zh": "开始安心同行",
    "fr": "Commencer Safe Companion",
    "pt": "Iniciar Safe Companion"
  },
  "시작 대기": {
    "en": "Ready to start",
    "ja": "開始待ち",
    "zh": "等待开始",
    "fr": "Prêt à démarrer",
    "pt": "Pronto para iniciar"
  },
  "진행 중": {
    "en": "In progress",
    "ja": "進行中",
    "zh": "进行中",
    "fr": "En cours",
    "pt": "Em andamento"
  },
  "시작": {
    "en": "Start",
    "ja": "開始",
    "zh": "开始",
    "fr": "Démarrer",
    "pt": "Iniciar"
  },
  "완료": {
    "en": "Complete",
    "ja": "完了",
    "zh": "完成",
    "fr": "Terminé",
    "pt": "Concluído"
  },
  "처리 중…": {
    "en": "Processing…",
    "ja": "処理中…",
    "zh": "处理中…",
    "fr": "Traitement…",
    "pt": "Processando…"
  },
  "확인 중": {
    "en": "Checking",
    "ja": "確認中",
    "zh": "检查中",
    "fr": "Vérification",
    "pt": "Verificando"
  },
  "연결 요청 읽기 실패:": {
    "en": "Cannot read requests:",
    "ja": "リクエスト読込失敗：",
    "zh": "无法读取请求：",
    "fr": "Lecture des demandes impossible :",
    "pt": "Falha ao ler solicitações:"
  },
  "로그인·이메일 인증 및 보호자 규칙 배포를 확인하세요.": {
    "en": "Check login, email verification and deployed sharing rules.",
    "ja": "ログイン・メール認証・共有ルールの公開を確認してください。",
    "zh": "请检查登录、邮箱验证和共享规则部署。",
    "fr": "Vérifiez connexion, e-mail et règles de partage.",
    "pt": "Confira login, verificação de e-mail e regras de compartilhamento."
  },
  "전화번호만으로 위치를 조회하지 않습니다. 상대가 아래 연결 요청을 승인하고 위치 공유를 시작해야 합니다.": {
    "en": "A phone number alone cannot locate someone. The person must approve your request and start sharing.",
    "ja": "電話番号だけでは位置を確認できません。相手の承認と共有開始が必要です。",
    "zh": "仅凭电话号码无法定位。对方必须批准请求并开始共享。",
    "fr": "Un numéro seul ne permet pas de localiser quelqu’un. La personne doit accepter et partager sa position.",
    "pt": "Um número sozinho não localiza ninguém. A pessoa deve aprovar e iniciar o compartilhamento."
  },
  "01 · 로그인과 이메일 인증": {
    "en": "01 · Sign in and verification",
    "ja": "01 · ログインと認証",
    "zh": "01 · 登录与验证",
    "fr": "01 · Connexion et vérification",
    "pt": "01 · Login e verificação"
  },
  "오르큐브 계정으로 로그인하세요. 신규 가입자는 받은 인증 메일의 링크를 누른 뒤 내 계정에서 인증 상태 새로고침을 선택합니다. 이메일 인증 완료라면 다시 인증하지 않습니다. 회원 집계는 가입·로그인 시 자동 연결을 시도하며 별도 버튼은 없습니다.": {
    "en": "Sign in with your ORQUBE account. For a new account, open the verification link in your email, then refresh verification in My account. Verified accounts do not need to verify again. Membership sync is automatic at sign-in; no extra button is needed.",
    "ja": "ORQUBEアカウントでログインします。新規登録後はメールの認証リンクを開き、アカウント画面で認証状態を更新してください。認証済みなら再認証は不要です。会員情報はログイン時に自動連携します。",
    "zh": "使用ORQUBE账户登录。新注册后打开邮件中的验证链接，在我的账户刷新验证状态。已验证账户无需重复验证。会员信息在登录时自动同步，无需额外按钮。",
    "fr": "Connectez-vous avec ORQUBE. Après inscription, ouvrez le lien reçu par e-mail puis actualisez la vérification dans Mon compte. Une adresse vérifiée ne nécessite pas de nouvelle validation. La synchronisation du membre est automatique.",
    "pt": "Entre com sua conta ORQUBE. Após o cadastro, abra o link no e-mail e atualize a verificação em Minha conta. Contas verificadas não precisam repetir isso. O vínculo de membro é automático ao entrar."
  },
  "02 · 안전산행": {
    "en": "02 · Safe hiking",
    "ja": "02 · 安全登山",
    "zh": "02 · 安全徒步",
    "fr": "02 · Randonnée sûre",
    "pt": "02 · Trilha segura"
  },
  "첫 화면에서 안전산행을 선택합니다. 내 위치로 GPS를 확인하고 보호자 연락처·귀환 계획을 설정한 뒤 산행 시작을 누릅니다. 위치 공유는 별도로 동의하고 시작해야 합니다. 하산 후 완료 또는 이동 종료를 누르고 공유가 종료됐는지 확인하세요.": {
    "en": "Choose Safe hiking. Check GPS, configure your contact and return plan, then start the hike. Location sharing requires separate consent and activation. End the trip after descending and check that sharing has stopped.",
    "ja": "安全登山を選択し、GPS・連絡先・帰還計画を確認して登山を開始します。位置共有には別途同意と開始操作が必要です。下山後は終了して共有停止を確認してください。",
    "zh": "选择安全徒步，确认GPS、联系人和返回计划后开始徒步。位置共享需单独同意并开启。下山后结束行程并确认共享已停止。",
    "fr": "Choisissez Randonnée, vérifiez le GPS, le contact et le retour prévu, puis démarrez. Le partage nécessite un consentement et une activation séparés. Terminez après la descente et vérifiez son arrêt.",
    "pt": "Escolha Trilha segura, confira GPS, contato e retorno previsto, e inicie. Compartilhar exige consentimento e ativação separados. Ao voltar, encerre e confirme que o compartilhamento parou."
  },
  "03 · 안심귀가": {
    "en": "03 · Safe return",
    "ja": "03 · 安心帰宅",
    "zh": "03 · 安全回家",
    "fr": "03 · Retour sécurisé",
    "pt": "03 · Volta segura"
  },
  "첫 화면에서 안심귀가를 선택합니다. 지도에서 목적지를 지정하고 귀가 시작을 누릅니다. 가족에게 공유하려면 가족·친구 위치 확인에서 연결을 승인한 후 이동 화면의 위치 공유를 시작하세요. 도착하면 이동 종료를 누릅니다. 도착 지연 자동 알림은 아직 제공하지 않습니다.": {
    "en": "Choose Safe return, select your destination on the map and start the trip. Approve a contact before enabling location sharing. End the trip when you arrive. Automatic late-arrival notifications are not provided yet.",
    "ja": "安心帰宅で目的地を指定して移動を開始します。位置共有の前に相手を承認してください。到着後は終了します。到着遅延の自動通知は未対応です。",
    "zh": "选择安全回家，在地图设置目的地并开始行程。开启位置共享前请批准联系人。到达后结束行程。目前不提供延迟到达自动通知。",
    "fr": "Choisissez Retour sécurisé, fixez la destination et démarrez. Autorisez un contact avant de partager. Terminez à l’arrivée. Les alertes automatiques de retard ne sont pas encore disponibles.",
    "pt": "Escolha Volta segura, defina o destino e inicie. Aprove o contato antes de compartilhar. Encerre ao chegar. Alertas automáticos de atraso ainda não estão disponíveis."
  },
  "04 · 가족·친구 위치 확인": {
    "en": "04 · Family and friends",
    "ja": "04 · 家族・友人",
    "zh": "04 · 家人朋友",
    "fr": "04 · Famille et amis",
    "pt": "04 · Familiares e amigos"
  },
  "양쪽 모두 로그인하고 이메일 인증을 완료해야 합니다. 위치를 공유할 사람이 내 연결 ID를 지정 보호자에게 전달합니다. 보호자가 그 ID로 연결 요청을 보내면 공유자가 요청자의 ID를 확인하고 승인합니다. 공유자가 이동 시작 후 위치 공유를 켜야 보호자가 승인 후 상대 위치 확인으로 현재 위치와 최근 경로를 볼 수 있습니다. 전화번호만으로 위치를 조회하지 않습니다.": {
    "en": "Both people must sign in and verify their email. The person sharing sends their connection ID to a trusted contact. That contact requests access; the sharer checks the requester ID and approves. After the sharer starts the trip and sharing, the contact can view current location and recent route. A phone number alone cannot locate someone.",
    "ja": "双方のログインとメール認証が必要です。共有者は接続IDを信頼する相手へ伝えます。相手が接続を申請し、共有者がIDを確認して承認します。移動と共有の開始後、相手が現在位置と直近ルートを確認できます。電話番号だけでは追跡できません。",
    "zh": "双方需登录并验证邮箱。共享者把连接ID告知可信联系人，联系人发送请求，共享者核对请求者ID并批准。开始行程及共享后，联系人可查看当前位置和最近路线。无法仅凭电话号码定位。",
    "fr": "Les deux personnes doivent se connecter et vérifier leur e-mail. Le partageur transmet son identifiant à un proche. Le proche demande l’accès ; le partageur vérifie l’identifiant et autorise. Après départ et activation, le proche voit position et trajet récent. Un numéro seul ne suffit pas.",
    "pt": "Ambos devem entrar e verificar o e-mail. Quem compartilha envia seu ID ao contato. O contato solicita acesso; o titular confere o ID e aprova. Após iniciar percurso e compartilhamento, o contato vê posição e percurso recente. Um número sozinho não permite localizar alguém."
  },
  "05 · 공유 종료와 접근 해제": {
    "en": "05 · Stop sharing and revoke access",
    "ja": "05 · 共有停止とアクセス解除",
    "zh": "05 · 停止共享与撤销权限",
    "fr": "05 · Arrêt du partage et révocation",
    "pt": "05 · Encerrar e revogar acesso"
  },
  "이동 종료 또는 위치 공유 중지로 공유를 종료합니다. 보호자 연결 화면의 승인된 보호자에서 해제를 누르면 해당 계정의 접근을 취소합니다. 갱신 간격은 약 15초이며 최근 경로 최대 500개 지점을 표시합니다. 마지막 서버 갱신 후 2분이 지나면 조회가 만료됩니다. 통신 단절 시 종료 반영이 지연될 수 있습니다.": {
    "en": "End the trip or stop sharing. Revoke a contact in Approved contacts to remove access. Updates are about every 15 seconds with up to 500 recent points. Viewer access expires after 2 minutes without a server update. Network loss may delay stopping on the server.",
    "ja": "移動終了または共有停止で終了します。承認済みの相手からアクセスを解除できます。約15秒間隔、直近最大500地点を表示します。サーバー更新が2分なければ閲覧は期限切れになります。通信断で終了反映が遅れる場合があります。",
    "zh": "结束行程或停止共享。在已批准联系人中撤销访问。约每15秒更新，最多显示最近500个点。服务器两分钟未更新则查看权限过期。断网可能延迟服务器停止共享。",
    "fr": "Terminez le trajet ou le partage. Révoquez un contact pour retirer son accès. Actualisation environ toutes les 15 secondes, jusqu’à 500 points. L’accès expire après 2 minutes sans mise à jour serveur. Une coupure peut retarder l’arrêt.",
    "pt": "Encerre o percurso ou pare de compartilhar. Revogue o contato para remover o acesso. Atualizações a cada 15 segundos aproximadamente, até 500 pontos. O acesso expira após 2 minutos sem atualização do servidor. Uma falha de rede pode atrasar o encerramento."
  },
  "06 · 문자·카카오톡과 SOS": {
    "en": "06 · Messages and SOS",
    "ja": "06 · メッセージとSOS",
    "zh": "06 · 消息与SOS",
    "fr": "06 · Messages et SOS",
    "pt": "06 · Mensagens e SOS"
  },
  "문자·메신저로 직접 보내는 지도 링크는 전송 당시의 좌표이며 실시간 추적 링크가 아닙니다. 수신자를 확인한 뒤 직접 전송하세요. SOS는 좌표 안내와 서버 기록이며 112·119 자동 신고나 구조 접수 보장이 아닙니다.": {
    "en": "Map links sent by SMS or messenger contain the location at sending time; they are not live tracking links. Check the recipient before sending. SOS provides coordinates and a server record; it does not automatically contact emergency services or guarantee rescue.",
    "ja": "SMSやメッセンジャーの地図リンクは送信時点の座標であり、リアルタイム追跡ではありません。送信先を確認してください。SOSは座標案内とサーバー記録で、緊急機関への自動通報や救助保証ではありません。",
    "zh": "短信或聊天发送的地图链接仅包含发送时坐标，并非实时跟踪链接。发送前核对收件人。SOS提供坐标和服务器记录，不会自动联系紧急服务，也不保证救援。",
    "fr": "Un lien envoyé par SMS ou messagerie indique la position à l’envoi, sans suivi en direct. Vérifiez le destinataire. SOS fournit les coordonnées et un enregistrement ; il n’appelle pas automatiquement les secours et ne garantit pas une intervention.",
    "pt": "Links por SMS ou mensageiro mostram a posição no envio, sem rastreamento ao vivo. Confira o destinatário. SOS fornece coordenadas e registro no servidor; não aciona automaticamente a emergência nem garante resgate."
  },
  "07 · 오프라인과 휴대폰 사용": {
    "en": "07 · Offline and device limits",
    "ja": "07 · オフラインと端末の制限",
    "zh": "07 · 离线与设备限制",
    "fr": "07 · Hors connexion et limites",
    "pt": "07 · Offline e limites do dispositivo"
  },
  "통신이 끊기면 보호자에게 최신 위치를 전송할 수 없습니다. 마지막 수신 시간을 확인하세요. 안전산행 저장 지도는 저장 당시 영역의 이미지입니다. 화면 종료·절전·강제 종료 시 경로 기록과 공유가 중단될 수 있으며 백그라운드 연속 공유는 검증되지 않았습니다.": {
    "en": "Without connectivity, contacts cannot receive your latest location. Check the last update time. Saved hiking maps are images of the saved area. Screen lock, battery saving or closing the app may interrupt recording and sharing. Continuous background sharing has not been verified.",
    "ja": "通信がなければ最新位置は届きません。最終更新時刻を確認してください。保存地図は保存範囲の画像です。画面ロック・省電力・アプリ終了で記録と共有が中断する場合があります。バックグラウンド連続共有は未検証です。",
    "zh": "无网络时无法向联系人发送最新位置，请查看最后更新时间。保存的徒步地图是对应区域的图片。锁屏、省电或关闭应用可能中断记录和共享。后台持续共享尚未验证。",
    "fr": "Sans réseau, vos proches ne reçoivent pas la dernière position. Vérifiez l’heure de mise à jour. Les cartes sauvegardées sont des images. Verrouillage, économie d’énergie ou fermeture peuvent interrompre le suivi. Le partage continu en arrière-plan n’est pas vérifié.",
    "pt": "Sem conexão, os contatos não recebem a posição mais recente. Confira a última atualização. Mapas salvos são imagens da área. Bloqueio, economia de bateria ou fechamento podem interromper registros e compartilhamento. O funcionamento contínuo em segundo plano não foi verificado."
  },
  "08 · 개인정보와 기록 관리": {
    "en": "08 · Privacy and account deletion",
    "ja": "08 · 個人情報と退会",
    "zh": "08 · 隐私与账户注销",
    "fr": "08 · Confidentialité et suppression",
    "pt": "08 · Privacidade e exclusão de conta"
  },
  "계정 ID·보호자 요청·승인 목록·공유 중 좌표와 최근 경로를 Firebase에 저장합니다. 지정해 승인한 보호자만 공유 중 위치를 확인하도록 규칙을 적용해야 합니다. 내 계정에서 기록 삭제·회원탈퇴를 진행할 수 있습니다. 회원탈퇴는 오르큐브 공통 로그인 계정에 영향을 줍니다. 외부 메시지로 보낸 좌표는 회수할 수 없습니다.": {
    "en": "Firebase stores account IDs, contact requests, approvals, shared coordinates and recent routes. Rules must restrict shared location to approved contacts. Delete trip records or your account in My account. Account deletion affects the shared ORQUBE login. Locations already sent in external messages cannot be recalled.",
    "ja": "FirebaseにアカウントID・接続申請・承認・共有座標・直近ルートを保存します。共有位置は承認した相手だけが閲覧できるルールが必要です。記録削除・退会はアカウント画面で行います。退会はORQUBE共通ログインに影響します。外部送信済みの位置は回収できません。",
    "zh": "Firebase保存账户ID、连接请求、批准列表、共享坐标及最近路线。需通过规则限制仅已批准联系人查看。可在我的账户删除记录或注销。注销影响ORQUBE共用登录账户。外部消息中已发送的位置无法撤回。",
    "fr": "Firebase conserve identifiants, demandes, autorisations, coordonnées et trajets récents. Les règles doivent limiter l’accès aux contacts autorisés. Supprimez trajets ou compte dans Mon compte. La suppression affecte le compte ORQUBE commun. Les positions envoyées à l’extérieur ne sont pas récupérables.",
    "pt": "O Firebase armazena IDs, solicitações, aprovações, coordenadas e percursos recentes. As regras devem limitar o acesso aos contatos aprovados. Exclua registros ou conta em Minha conta. Excluir afeta o login comum ORQUBE. Posições enviadas por mensagens externas não podem ser recolhidas."
  },
  "본인의 산행·공유 위치·SOS 기록과 보호자 설정, 기기 저장 지도를 삭제합니다. 복구할 수 없습니다. 다른 ORQUBE 서비스 기록은 삭제하지 않습니다.": {
    "en": "Delete your trip, shared location, SOS records, contact settings and saved map. This cannot be undone. Other ORQUBE service records are not deleted.",
    "ja": "移動・共有位置・SOS記録・保護者設定・保存地図を削除します。復元できません。他のORQUBE記録は削除しません。",
    "zh": "删除本人的行程、共享位置、SOS记录、联系人设置和保存地图。不可恢复。不删除其他ORQUBE服务记录。",
    "fr": "Supprime trajets, positions, SOS, contacts et carte sauvegardée. Irréversible. Les autres données ORQUBE ne sont pas supprimées.",
    "pt": "Exclui percursos, posições, SOS, contatos e mapa salvo. Irreversível. Outros registros ORQUBE não são excluídos."
  },
  "이 Firebase 프로젝트의 ORQUBE 공통 로그인 계정이 삭제됩니다. 산행 기록은 먼저 삭제하지만 다른 앱의 별도 데이터는 남을 수 있습니다. 계속하시겠습니까?": {
    "en": "This deletes the shared ORQUBE login account in this Firebase project. Trip records are deleted first; separate data in other apps may remain. Continue?",
    "ja": "このFirebaseのORQUBE共通ログインを削除します。移動記録は先に削除しますが他アプリのデータが残る場合があります。続行しますか？",
    "zh": "将删除此Firebase项目中的ORQUBE共用登录账户。行程记录先删除，其他应用的数据可能保留。继续吗？",
    "fr": "Le compte ORQUBE commun sera supprimé. Les trajets sont supprimés d’abord ; des données d’autres applications peuvent rester. Continuer ?",
    "pt": "A conta de login comum ORQUBE será excluída. Percursos são apagados antes; dados separados de outros apps podem permanecer. Continuar?"
  },
  "탈퇴 확인용 현재 비밀번호": {
    "en": "Current password to confirm deletion",
    "ja": "退会確認用の現在のパスワード",
    "zh": "用于确认注销的当前密码",
    "fr": "Mot de passe pour confirmer la suppression",
    "pt": "Senha atual para confirmar exclusão"
  },
  "회원탈퇴가 완료되었습니다.": {
    "en": "Account deleted.",
    "ja": "退会しました。",
    "zh": "账户已注销。",
    "fr": "Compte supprimé.",
    "pt": "Conta excluída."
  },
  "현재 위치와 최근 이동 경로를 서버에 저장하고, 보호자 연결 화면에서 내가 승인한 계정에 공개합니다. 전화번호만으로 조회할 수 없습니다. 이동 종료 또는 공유 중지 시 접근을 차단합니다. 인터넷 단절 시 종료 반영이 지연될 수 있으며 마지막 갱신 2분 뒤 보호자 조회가 만료됩니다.": {
    "en": "Your current location and recent route are stored on the server and shown to contacts you approved. A phone number alone cannot locate you. End the trip or stop sharing to block access. Network loss may delay stopping; access expires 2 minutes after the last update.",
    "ja": "現在位置と直近ルートをサーバーに保存し、承認済みの相手へ公開します。電話番号だけでは閲覧できません。移動終了・共有停止でアクセスを停止します。通信断で反映が遅れる場合があり、最終更新2分後に閲覧期限が切れます。",
    "zh": "当前位置和最近路线存储在服务器，仅向已批准联系人开放。无法仅凭电话号码查看。结束行程或停止共享可阻止访问。断网可能延迟生效，最后更新两分钟后查看权限过期。",
    "fr": "Votre position et trajet récent sont stockés et partagés avec les contacts autorisés. Un numéro seul ne suffit pas. Terminez le trajet ou le partage pour bloquer l’accès. Une coupure peut retarder l’arrêt ; accès expiré 2 minutes après la dernière mise à jour.",
    "pt": "Sua posição e percurso recente são armazenados e mostrados aos contatos aprovados. Um número sozinho não permite localizar. Encerre ou pare de compartilhar para bloquear acesso. Falhas de rede podem atrasar; acesso expira 2 minutos após a última atualização."
  },
  "안전산행·안심귀가·가족과 친구 위치 확인을 제공합니다. 승인한 보호자와 이동 중 위치·최근 경로를 공유할 수 있습니다. GPS 경로·출발점·귀환 계획과 저장 지도 기능도 제공합니다. 실제 위치 권한은 내 위치 또는 산행 시작을 누를 때 요청합니다. 권한을 거부해도 설명서를 볼 수 있습니다.": {
    "en": "Safe hiking, safe return and trusted location sharing. GPS permission is requested when you check your location or start a trip. You can read the guide without granting permission.",
    "ja": "登山・帰宅・信頼する相手との位置共有。現在位置の確認や移動開始時にGPS権限を求めます。権限なしでもガイドを閲覧できます。",
    "zh": "提供安全徒步、安全回家及可信位置共享。查看位置或开始行程时请求GPS权限。拒绝权限仍可阅读指南。",
    "fr": "Randonnée, retour et partage de position. Le GPS est demandé à la consultation ou au départ. Le guide reste accessible sans permission.",
    "pt": "Trilha, volta e localização compartilhada. O GPS é solicitado ao consultar sua posição ou iniciar. O guia pode ser lido sem permissão."
  },
  "개인정보 안내\n이메일은 Firebase 인증에 사용합니다. 보호자 이름·연락처와 위치·시간·산행 상태는 기능 이용 시 Firebase 서버에 저장됩니다. 보호자 연락처 등록만으로 알림이 발송되지 않습니다. 지도 제공자·주소 검색·길찾기 서비스에는 요청한 지역 또는 좌표가 전달될 수 있습니다.\n\n기록은 직접 삭제할 때까지 보관될 수 있습니다. 계정 화면에서 산행 기록 삭제·회원탈퇴를 할 수 있습니다. 외부 메시지로 보낸 위치는 앱에서 회수할 수 없습니다.": {
    "en": "Privacy\nFirebase handles email authentication and stores contact details, location, time and trip status when used. Adding a contact does not send notifications. Map, address and routing providers may receive requested areas or coordinates. Records may remain until deleted. Delete records or your account in My account. External location messages cannot be recalled.",
    "ja": "個人情報\nメール認証にFirebaseを使用し、連絡先・位置・時刻・移動状態を保存します。連絡先登録だけでは通知しません。地図・住所・経路サービスに地域や座標を送る場合があります。記録は削除まで保存される場合があります。アカウント画面で削除・退会できます。外部送信済み位置は回収できません。",
    "zh": "隐私\nFirebase用于邮箱认证，并在使用时保存联系人、位置、时间及行程状态。添加联系人不会自动通知。地图、地址和路线提供方可能收到查询区域或坐标。记录可能保存至主动删除。可在我的账户删除记录或注销。外发位置消息无法撤回。",
    "fr": "Confidentialité\nFirebase gère l’authentification et stocke contacts, position, heure et état du trajet. Ajouter un contact n’envoie aucune notification. Les fournisseurs de carte, adresse et itinéraire peuvent recevoir zones ou coordonnées. Conservation possible jusqu’à suppression. Suppression dans Mon compte. Les messages externes ne sont pas récupérables.",
    "pt": "Privacidade\nFirebase autentica o e-mail e armazena contatos, posição, horário e estado do percurso. Adicionar contato não envia notificações. Provedores de mapa, endereço e rota podem receber áreas ou coordenadas. Registros podem permanecer até exclusão em Minha conta. Mensagens externas não podem ser recolhidas."
  },
  "지원 범위\nSOS는 서버 기록 및 좌표 안내이며 119 자동 신고가 아닙니다. 저장 지도는 현재 화면 영역의 이미지입니다. 앱 종료·기기 절전·GPS 불량 시 기록이 중단될 수 있습니다. 백신 검사·외부 보안 인증을 받은 앱이라는 표시는 사용하지 않습니다.": {
    "en": "Service limits\nSOS records coordinates on the server; it does not automatically call emergency services. A saved map is an image of the saved area. Closing the app, battery saving or GPS issues may stop recording. No antivirus test or external security certification is claimed.",
    "ja": "対応範囲\nSOSは座標の案内と記録で、緊急機関への自動通報ではありません。保存地図は画像です。終了・省電力・GPS不良で記録が止まる場合があります。ウイルス検査や外部セキュリティ認証取得は表示しません。",
    "zh": "服务范围\nSOS记录服务器坐标，不会自动呼叫紧急服务。保存地图是对应区域图片。关闭应用、省电或GPS问题可能中断记录。不宣称已通过病毒检测或外部安全认证。",
    "fr": "Limites\nSOS enregistre les coordonnées sans appeler automatiquement les secours. Une carte sauvegardée est une image. Fermeture, économie d’énergie ou GPS défaillant peuvent arrêter le suivi. Aucune certification de sécurité externe ni analyse antivirus n’est revendiquée.",
    "pt": "Limites\nSOS registra coordenadas sem chamar automaticamente a emergência. Mapa salvo é uma imagem. Fechamento, economia de bateria ou falha de GPS podem interromper registros. Não se alega certificação externa de segurança nem teste antivírus."
  },
  "통합 V2.3 · 위치 공유는 이동 화면의 공유 버튼으로 시작합니다. 보호자도 로그인해야 합니다. 문자로 보낸 지도 좌표는 실시간 링크가 아닙니다. 화면 종료·절전·통신 단절 시 갱신이 중단될 수 있습니다.": {
    "en": "V2.3 · Start sharing from the trip screen. Contacts must sign in. SMS map links are snapshots, not live tracking. Closing the screen, battery saving or network loss may stop updates.",
    "ja": "V2.3・移動画面で共有を開始します。相手もログインが必要です。SMSリンクは送信時点の位置です。画面終了・省電力・通信断で更新が止まる場合があります。",
    "zh": "V2.3·在行程页面开始共享。联系人需登录。短信地图链接不是实时跟踪。关闭屏幕、省电或断网可能中断更新。",
    "fr": "V2.3 · Activez le partage depuis le trajet. Les proches doivent se connecter. Les liens SMS ne sont pas un suivi direct. Fermeture, économie d’énergie ou réseau peuvent interrompre les mises à jour.",
    "pt": "V2.3 · Inicie o compartilhamento na tela do percurso. Contatos devem entrar. Links SMS não são rastreamento ao vivo. Fechamento, bateria ou rede podem interromper atualizações."
  },
  "위치 갱신은 약 15초 간격입니다. 마지막 서버 갱신 후 2분이 지나면 보호자 조회가 만료됩니다. 서버에 종료가 전달되기 전에는 이전 위치가 잠시 보일 수 있습니다.": {
    "en": "Updates are about every 15 seconds. Access expires 2 minutes after the last server update. Previous locations may remain briefly until the server receives the stop request.",
    "ja": "約15秒間隔で更新。サーバー更新が2分なければ閲覧期限が切れます。停止が届くまで前の位置が一時表示される場合があります。",
    "zh": "约15秒更新。服务器两分钟未更新则查看过期。停止请求到达前旧位置可能暂时可见。",
    "fr": "Mise à jour environ toutes les 15 secondes. Accès expiré après 2 minutes sans mise à jour serveur. L’ancienne position peut rester visible jusqu’à réception de l’arrêt.",
    "pt": "Atualizações a cada 15 segundos. O acesso expira após 2 minutos sem atualização. A posição anterior pode permanecer até o servidor receber o encerramento."
  },
  "실시간 이동 지도": {
    "en": "Live travel map",
    "ja": "リアルタイム移動マップ",
    "zh": "实时移动地图",
    "fr": "Carte de déplacement en direct",
    "pt": "Mapa de deslocamento ao vivo"
  },
  "위치 갱신 중": {
    "en": "Receiving location updates",
    "ja": "位置を更新中",
    "zh": "位置更新中",
    "fr": "Mise à jour de position",
    "pt": "Recebendo atualizações"
  },
  "저장된 위치 · 서버 연결 확인 필요": {
    "en": "Cached location · Check connection",
    "ja": "保存位置・接続を確認",
    "zh": "缓存位置·请检查连接",
    "fr": "Position en cache · Vérifier la connexion",
    "pt": "Posição em cache · Confira a conexão"
  },
  "위치 수신 지연 · 마지막 위치 표시": {
    "en": "Updates delayed · Last received location",
    "ja": "受信遅延・最終位置を表示",
    "zh": "接收延迟·显示最后位置",
    "fr": "Réception retardée · Dernière position",
    "pt": "Recepção atrasada · Última posição"
  },
  "위치 공유가 종료되었습니다.": {
    "en": "Location sharing has ended.",
    "ja": "位置共有が終了しました。",
    "zh": "位置共享已结束。",
    "fr": "Le partage de position est terminé.",
    "pt": "O compartilhamento foi encerrado."
  },
  "위치 공유가 만료되었습니다. 상대방의 공유 상태를 확인하세요.": {
    "en": "Sharing has expired. Check the other person’s sharing status.",
    "ja": "共有期限が切れました。相手の共有状態を確認してください。",
    "zh": "共享已过期，请检查对方的共享状态。",
    "fr": "Partage expiré. Vérifiez l’état du partage du proche.",
    "pt": "Compartilhamento expirou. Confira o estado da outra pessoa."
  },
  "상대방 따라가기": {
    "en": "Follow location",
    "ja": "相手を追従",
    "zh": "跟随对方",
    "fr": "Suivre la position",
    "pt": "Seguir localização"
  },
  "전체 경로 보기": {
    "en": "View full route",
    "ja": "全ルートを表示",
    "zh": "查看完整路线",
    "fr": "Voir tout le trajet",
    "pt": "Ver percurso completo"
  },
  "파란 선은 최근 이동 경로입니다. 통신이 지연되면 마지막 좌표에서 멈춥니다.": {
    "en": "Blue shows the recent route. Delayed updates stop at the last received fix.",
    "ja": "青線は直近ルートです。受信が遅れると最終座標で止まります。",
    "zh": "蓝线是最近路线，通信延迟时停在最后坐标。",
    "fr": "Le bleu montre le trajet récent. En cas de retard, arrêt à la dernière position reçue.",
    "pt": "Azul mostra o percurso recente. Se houver atraso, para na última posição recebida."
  },
  "이동 중 전송 목표는 약 5초, 정지 시 약 15초입니다. 수신이 20초 이상 지연되면 마지막 위치로 표시하며, 갱신 후 2분이 지나면 조회가 만료됩니다. 실제 갱신은 GPS·통신·절전 상태에 따라 달라집니다.": {
    "en": "Target updates: about 5 seconds moving, 15 seconds stationary. After 20 seconds without updates, show the last position; access expires after 2 minutes. GPS, network and power settings affect actual timing.",
    "ja": "移動中約5秒、停止中約15秒を目標に送信。20秒以上受信がなければ最終位置を表示し、2分で期限切れになります。実際の間隔はGPS・通信・省電力設定で変わります。",
    "zh": "目标为移动时约5秒、静止约15秒。超过20秒未更新则显示最后位置，2分钟后过期。实际间隔取决于GPS、网络和省电设置。",
    "fr": "Objectif : environ 5 s en mouvement, 15 s à l’arrêt. Après 20 s de retard, dernière position ; expiration après 2 min. GPS, réseau et énergie modifient le délai réel.",
    "pt": "Meta: cerca de 5 s em movimento, 15 s parado. Após 20 s de atraso, mostra a última posição; expira após 2 min. GPS, rede e energia afetam o intervalo real."
  },
  "목적지가 설정되었습니다.": {
    "en": "Destination has been set.",
    "ja": "目的地が設定されました。",
    "zh": "目的地已设置。",
    "fr": "La destination a été définie.",
    "pt": "O destino foi definido."
  },
  "계산 중...": {
    "en": "Calculating...",
    "ja": "計算中...",
    "zh": "计算中...",
    "fr": "Calcul en cours...",
    "pt": "Calculando..."
  },
  "목적지 미설정": {
    "en": "Destination not set",
    "ja": "目的地未設定",
    "zh": "未设置目的地",
    "fr": "Destination non définie",
    "pt": "Destino não definido"
  },
  "귀환시간 미설정": {
    "en": "Return time not set",
    "ja": "帰還時刻未設定",
    "zh": "未设置返回时间",
    "fr": "Heure de retour non définie",
    "pt": "Horário de retorno não definido"
  },
  "기기의 위치 서비스를 먼저 켜주세요.": {
    "en": "Turn on the device location service first.",
    "ja": "端末の位置情報サービスをオンにしてください。",
    "zh": "请先开启设备定位服务。",
    "fr": "Activez d’abord le service de localisation de l’appareil.",
    "pt": "Ative primeiro o serviço de localização do dispositivo."
  },
  "현재 위치를 사용하려면 위치 권한이 필요합니다.": {
    "en": "Location permission is required to use your current location.",
    "ja": "現在地を使用するには位置情報の許可が必要です。",
    "zh": "使用当前位置需要定位权限。",
    "fr": "L’autorisation de localisation est nécessaire pour utiliser votre position.",
    "pt": "É necessária permissão de localização para usar sua posição."
  },
  "설정에서 ORQUBE의 위치 권한을 허용해주세요.": {
    "en": "Allow ORQUBE location permission in Settings.",
    "ja": "設定でORQUBEの位置情報権限を許可してください。",
    "zh": "请在设置中允许 ORQUBE 使用定位权限。",
    "fr": "Autorisez ORQUBE à accéder à la localisation dans les réglages.",
    "pt": "Permita que o ORQUBE acesse a localização nas configurações."
  },
  "현재 위치를 확인하지 못했습니다:": {
    "en": "Could not get current location:",
    "ja": "現在地を取得できませんでした:",
    "zh": "无法获取当前位置：",
    "fr": "Impossible d’obtenir la position actuelle :",
    "pt": "Não foi possível obter a localização atual:"
  },
  "로그인 후 경기장을 등록할 수 있습니다.": {
    "en": "Sign in to register a field.",
    "ja": "ログイン後にフィールドを登録できます。",
    "zh": "登录后可登记场地。",
    "fr": "Connectez-vous pour enregistrer un terrain.",
    "pt": "Faça login para cadastrar um campo."
  },
  "현재 위치를 경기장으로 등록": {
    "en": "Register Current Location as Field",
    "ja": "現在地をフィールドとして登録",
    "zh": "将当前位置登记为场地",
    "fr": "Enregistrer la position actuelle comme terrain",
    "pt": "Cadastrar a localização atual como campo"
  },
  "경기장 이름": {
    "en": "Field name",
    "ja": "フィールド名",
    "zh": "场地名称",
    "fr": "Nom du terrain",
    "pt": "Nome do campo"
  },
  "주소 또는 지역": {
    "en": "Address or region",
    "ja": "住所または地域",
    "zh": "地址或地区",
    "fr": "Adresse ou région",
    "pt": "Endereço ou região"
  },
  "시설 설명·주차·안전수칙": {
    "en": "Facilities · parking · safety rules",
    "ja": "施設説明・駐車・安全ルール",
    "zh": "设施说明·停车·安全规则",
    "fr": "Installations · stationnement · consignes de sécurité",
    "pt": "Instalações · estacionamento · regras de segurança"
  },
  "위도": {
    "en": "Latitude",
    "ja": "緯度",
    "zh": "纬度",
    "fr": "Latitude",
    "pt": "Latitude"
  },
  "경도": {
    "en": "Longitude",
    "ja": "経度",
    "zh": "经度",
    "fr": "Longitude",
    "pt": "Longitude"
  },
  "경기장 이름을 2자 이상 입력해주세요.": {
    "en": "Enter at least 2 characters for the field name.",
    "ja": "フィールド名を2文字以上入力してください。",
    "zh": "场地名称至少输入2个字符。",
    "fr": "Saisissez au moins 2 caractères pour le nom du terrain.",
    "pt": "Digite pelo menos 2 caracteres para o nome do campo."
  },
  "등록": {
    "en": "Register",
    "ja": "登録",
    "zh": "登记",
    "fr": "Enregistrer",
    "pt": "Cadastrar"
  },
  "경기장이 등록되었습니다. 관리자 승인 전에는 등록자에게만 표시될 수 있습니다.": {
    "en": "The field was registered. Before admin approval, it may be visible only to you.",
    "ja": "フィールドを登録しました。管理者承認前は登録者のみに表示される場合があります。",
    "zh": "场地已登记。管理员批准前可能仅对登记者显示。",
    "fr": "Le terrain a été enregistré. Avant validation, il peut n’être visible que par son auteur.",
    "pt": "O campo foi cadastrado. Antes da aprovação, ele pode aparecer apenas para quem cadastrou."
  },
  "경기장 등록 실패:": {
    "en": "Field registration failed:",
    "ja": "フィールド登録に失敗しました:",
    "zh": "场地登记失败：",
    "fr": "Échec de l’enregistrement du terrain :",
    "pt": "Falha ao cadastrar o campo:"
  },
  "로그인 후 안전 위치 공유를 사용할 수 있습니다.": {
    "en": "Sign in to use safety location sharing.",
    "ja": "ログイン後に安全位置共有を利用できます。",
    "zh": "登录后可使用安全位置共享。",
    "fr": "Connectez-vous pour utiliser le partage de position de sécurité.",
    "pt": "Faça login para usar o compartilhamento seguro de localização."
  },
  "안전 위치 공유": {
    "en": "Safety Location Sharing",
    "ja": "安全位置共有",
    "zh": "安全位置共享",
    "fr": "Partage de position de sécurité",
    "pt": "Compartilhamento seguro de localização"
  },
  "현재 위치를 30분 동안 운영자와 허용된 안전 담당자에게 공유합니다. 상대 팀 추적에는 사용할 수 없으며 언제든 종료할 수 있습니다.": {
    "en": "Your current location will be shared for 30 minutes with operators and authorized safety staff. It cannot be used to track opposing teams and can be stopped at any time.",
    "ja": "現在地を30分間、運営者と許可された安全担当者に共有します。相手チームの追跡には使用できず、いつでも終了できます。",
    "zh": "当前位置将与运营方和获授权的安全负责人共享30分钟。不得用于追踪对方队伍，并可随时停止。",
    "fr": "Votre position est partagée pendant 30 minutes avec les opérateurs et responsables de sécurité autorisés. Elle ne peut pas servir à suivre l’équipe adverse et peut être arrêtée à tout moment.",
    "pt": "Sua localização será compartilhada por 30 minutos com operadores e responsáveis de segurança autorizados. Não pode ser usada para rastrear a equipe adversária e pode ser encerrada a qualquer momento."
  },
  "동의하고 시작": {
    "en": "Agree and Start",
    "ja": "同意して開始",
    "zh": "同意并开始",
    "fr": "Accepter et démarrer",
    "pt": "Concordar e iniciar"
  },
  "안전 위치 공유가 시작되었습니다. 통신 상태에 따라 전달이 지연될 수 있습니다.": {
    "en": "safety location sharing has started. Delivery may be delayed depending on connectivity.",
    "ja": "安全位置共有を開始しました。通信状況により送信が遅れる場合があります。",
    "zh": "安全位置共享已开始。根据网络状况，传输可能延迟。",
    "fr": "Le partage de position de sécurité a commencé. La transmission peut être retardée selon le réseau.",
    "pt": "O compartilhamento seguro de localização começou. A transmissão pode atrasar conforme a rede."
  },
  "GPS 기록은 계속됩니다. 현재 통신이 원활하지 않아 실시간 위치 공유는 지연될 수 있습니다.": {
    "en": "GPS recording continues. Real-time location sharing may be delayed because connectivity is currently unstable.",
    "ja": "GPS記録は継続します。現在通信が不安定なため、リアルタイム共有が遅れる場合があります。",
    "zh": "GPS 记录将继续。当前网络不畅，实时位置共享可能延迟。",
    "fr": "L’enregistrement GPS continue. La connexion est instable, le partage en temps réel peut être retardé.",
    "pt": "O registro de GPS continua. A conexão está instável e o compartilhamento em tempo real pode atrasar."
  },
  "로그인 후 SOS를 사용할 수 있습니다.": {
    "en": "Sign in to use SOS.",
    "ja": "ログイン後にSOSを利用できます。",
    "zh": "登录后可使用 SOS。",
    "fr": "Connectez-vous pour utiliser le SOS.",
    "pt": "Faça login para usar o SOS."
  },
  "긴급 상황 선택": {
    "en": "Select Emergency",
    "ja": "緊急状況を選択",
    "zh": "选择紧急情况",
    "fr": "Choisir l’urgence",
    "pt": "Selecionar emergência"
  },
  "현재 위치가 안전 담당자에게 전달됩니다.": {
    "en": "Your current location will be sent to safety staff.",
    "ja": "現在地が安全担当者に送信されます。",
    "zh": "当前位置将发送给安全负责人。",
    "fr": "Votre position actuelle sera transmise au responsable de sécurité.",
    "pt": "Sua localização atual será enviada ao responsável de segurança."
  },
  "길을 잃었습니다": {
    "en": "I am lost",
    "ja": "道に迷いました",
    "zh": "我迷路了",
    "fr": "Je suis perdu",
    "pt": "Estou perdido"
  },
  "부상을 입었습니다": {
    "en": "I am injured",
    "ja": "けがをしました",
    "zh": "我受伤了",
    "fr": "Je suis blessé",
    "pt": "Estou ferido"
  },
  "장비 문제가 발생했습니다": {
    "en": "Equipment problem",
    "ja": "装備に問題が発生しました",
    "zh": "装备出现问题",
    "fr": "J’ai un problème d’équipement",
    "pt": "Há um problema com o equipamento"
  },
  "차량 지원이 필요합니다": {
    "en": "Vehicle assistance needed",
    "ja": "車両支援が必要です",
    "zh": "需要车辆支援",
    "fr": "J’ai besoin d’une assistance véhicule",
    "pt": "Preciso de apoio de veículo"
  },
  "기타 긴급 상황": {
    "en": "Other emergency",
    "ja": "その他の緊急事態",
    "zh": "其他紧急情况",
    "fr": "Autre urgence",
    "pt": "Outra emergência"
  },
  "SOS 전송 확인": {
    "en": "Confirm SOS",
    "ja": "SOS送信確認",
    "zh": "确认发送 SOS",
    "fr": "Confirmer l’envoi du SOS",
    "pt": "Confirmar envio do SOS"
  },
  "현재 위치를 긴급 전송합니다.": {
    "en": "Your current location will be sent as an emergency.",
    "ja": "現在地を緊急送信します。",
    "zh": "将紧急发送当前位置。",
    "fr": "Votre position actuelle sera envoyée en urgence.",
    "pt": "Sua localização atual será enviada como emergência."
  },
  "SOS 전송": {
    "en": "Send SOS",
    "ja": "SOS送信",
    "zh": "发送 SOS",
    "fr": "Envoyer le SOS",
    "pt": "Enviar SOS"
  },
  "SOS 위치 정보": {
    "en": "SOS Location Information",
    "ja": "SOS位置情報",
    "zh": "SOS 位置信息",
    "fr": "Informations de position SOS",
    "pt": "Informações de localização SOS"
  },
  "SOS 정보가 기기에 기록되어 서버 전송을 시도했습니다. 통신 상태에 따라 실제 전달이 지연될 수 있습니다.": {
    "en": "SOS information was recorded on the device and a server send was attempted. Actual delivery may be delayed depending on connectivity.",
    "ja": "SOS情報を端末に記録し、サーバー送信を試みました。通信状況により実際の送信が遅れる場合があります。",
    "zh": "SOS 信息已记录在设备中并尝试发送到服务器。根据网络状况，实际传输可能延迟。",
    "fr": "Les informations SOS ont été enregistrées sur l’appareil et l’envoi au serveur a été tenté. La transmission réelle peut être retardée selon le réseau.",
    "pt": "As informações de SOS foram registradas no dispositivo e o envio ao servidor foi tentado. A transmissão pode atrasar conforme a rede."
  },
  "현재 데이터 통신이 원활하지 않습니다. 아래 좌표를 직접 확인하고 가능한 통신 수단으로 전달하세요.": {
    "en": "Data connectivity is currently unstable. Check the coordinates below and share them through any available communication method.",
    "ja": "現在データ通信が不安定です。下の座標を確認し、利用可能な通信手段で伝えてください。",
    "zh": "当前数据网络不畅。请直接查看下方坐标，并通过可用的通信方式发送。",
    "fr": "La connexion de données est instable. Vérifiez les coordonnées ci-dessous et transmettez-les par un moyen de communication disponible.",
    "pt": "A conexão de dados está instável. Confira as coordenadas abaixo e envie-as por um meio de comunicação disponível."
  },
  "GPS 오차 약": {
    "en": "GPS accuracy about",
    "ja": "GPS誤差 約",
    "zh": "GPS 误差约",
    "fr": "Précision GPS env.",
    "pt": "Erro GPS aprox."
  },
  "고도": {
    "en": "Altitude",
    "ja": "高度",
    "zh": "海拔",
    "fr": "Altitude",
    "pt": "Altitude"
  },
  "현재 위치 좌표를 복사했습니다.": {
    "en": "Current location coordinates copied.",
    "ja": "現在地の座標をコピーしました。",
    "zh": "已复制当前位置坐标。",
    "fr": "Coordonnées actuelles copiées.",
    "pt": "Coordenadas atuais copiadas."
  },
  "좌표 복사": {
    "en": "Copy coordinates",
    "ja": "座標をコピー",
    "zh": "复制坐标",
    "fr": "Copier les coordonnées",
    "pt": "Copiar coordenadas"
  },
  "길찾기 앱을 사용할 수 없습니다.": {
    "en": "Directions app is unavailable.",
    "ja": "ナビゲーションアプリを使用できません。",
    "zh": "无法使用导航应用。",
    "fr": "L’application d’itinéraire n’est pas disponible.",
    "pt": "O aplicativo de navegação não está disponível."
  },
  "길찾기 앱을 열지 못했습니다.": {
    "en": "Could not open the directions app.",
    "ja": "ナビゲーションアプリを開けませんでした。",
    "zh": "无法打开导航应用。",
    "fr": "Impossible d’ouvrir l’application d’itinéraire.",
    "pt": "Não foi possível abrir o aplicativo de navegação."
  },
  "길찾기 실행 중 오류가 발생했습니다.": {
    "en": "An error occurred while launching directions.",
    "ja": "ナビゲーションの起動中にエラーが発生しました。",
    "zh": "启动导航时发生错误。",
    "fr": "Une erreur est survenue au lancement de l’itinéraire.",
    "pt": "Ocorreu um erro ao iniciar a navegação."
  },
  "에어소프트 경기": {
    "en": "Airsoft Match",
    "ja": "エアソフト試合",
    "zh": "Airsoft 比赛",
    "fr": "Match Airsoft",
    "pt": "Jogo de Airsoft"
  },
  "기존 경기장 지도, 장소 등록, 길찾기와 안전 기능을 그대로 사용합니다.": {
    "en": "Use the existing field map, place registration, directions, and safety features.",
    "ja": "既存のフィールド地図、場所登録、ナビゲーション、安全機能をそのまま利用できます。",
    "zh": "继续使用现有场地地图、地点登记、导航和安全功能。",
    "fr": "Utilisez la carte des terrains, l’ajout de lieux, l’itinéraire et les fonctions de sécurité existantes.",
    "pt": "Use normalmente o mapa de campos, cadastro de locais, rotas e recursos de segurança."
  },
  "사용자가 직접 시작한 경우에만 위치가 공유됩니다. 목적지·보호자 공유·예상 도착시간 기능을 확장할 수 있는 기본 구조입니다.": {
    "en": "Location is shared only when the user starts it. This provides the base for destination, guardian sharing, and ETA features.",
    "ja": "ユーザーが自分で開始した場合にのみ位置が共有されます。目的地、保護者共有、到着予定時刻を拡張できる基本構造です。",
    "zh": "仅在用户主动启动后共享位置。该基础结构可扩展目的地、监护人共享和预计到达时间功能。",
    "fr": "La position n’est partagée que si l’utilisateur démarre lui-même la fonction. Cette base permet d’étendre destination, partage avec un proche et heure d’arrivée estimée.",
    "pt": "A localização só é compartilhada quando o usuário inicia a função. A estrutura permite ampliar destino, compartilhamento com responsável e previsão de chegada."
  },
  "산행 시작 시 출발점과 GPS 이동 경로를 기기에서 계속 표시합니다. 인터넷이 끊겨도 GPS가 잡히면 좌표·고도·이동거리·출발점 방향을 확인할 수 있습니다.": {
    "en": "When hiking starts, the device keeps showing the start point and GPS route. Even without Internet, a GPS fix lets you check coordinates, altitude, distance, and direction to the start.",
    "ja": "登山開始時に出発点とGPS移動経路を端末に表示し続けます。インターネットが切れてもGPSが取得できれば、座標・高度・移動距離・出発点方向を確認できます。",
    "zh": "开始徒步后，设备会持续显示起点和 GPS 移动轨迹。即使断网，只要 GPS 可用，也能查看坐标、海拔、移动距离和起点方向。",
    "fr": "Au départ de la randonnée, le point de départ et la trace GPS restent affichés sur l’appareil. Même sans Internet, si le GPS fonctionne, vous pouvez consulter coordonnées, altitude, distance et direction du départ.",
    "pt": "Ao iniciar a trilha, o ponto de partida e o trajeto GPS continuam visíveis no dispositivo. Mesmo sem internet, com GPS disponível, é possível ver coordenadas, altitude, distância e direção do início."
  },
  "목적지 주소 검색": {
    "en": "Search Destination",
    "ja": "目的地住所検索",
    "zh": "搜索目的地地址",
    "fr": "Rechercher une destination",
    "pt": "Pesquisar destino"
  },
  "도로명·지번·장소명": {
    "en": "Address or place",
    "ja": "住所・地番・施設名",
    "zh": "道路名·门牌号·地点名称",
    "fr": "Adresse ou lieu",
    "pt": "Endereço ou local"
  },
  "예: 서울역, 대전시청": {
    "en": "Example: Seoul Station",
    "ja": "例：ソウル駅、大田市庁",
    "zh": "例如：首尔站、大田市政府",
    "fr": "Ex. : gare de Séoul",
    "pt": "Ex.: Estação de Seul"
  },
  "주소를 찾지 못했습니다.": {
    "en": "Address not found.",
    "ja": "住所が見つかりませんでした。",
    "zh": "未找到地址。",
    "fr": "Adresse introuvable.",
    "pt": "Endereço não encontrado."
  },
  "또는 창을 닫은 뒤 지도에서 목적지를 한 번 누르세요.": {
    "en": "Or close this window and tap the destination on the map.",
    "ja": "またはこの画面を閉じて、地図上の目的地を一度タップしてください。",
    "zh": "或者关闭此窗口后，在地图上点击一次目的地。",
    "fr": "Ou fermez cette fenêtre puis touchez la destination sur la carte.",
    "pt": "Ou feche esta janela e toque uma vez no destino no mapa."
  },
  "검색·선택": {
    "en": "Search",
    "ja": "検索・選択",
    "zh": "搜索并选择",
    "fr": "Rechercher",
    "pt": "Pesquisar"
  },
  "로그인 후 사용할 수 있습니다.": {
    "en": "Please sign in to use this feature.",
    "ja": "ログイン後に利用できます。",
    "zh": "登录后可使用。",
    "fr": "Connectez-vous pour utiliser cette fonction.",
    "pt": "Faça login para usar este recurso."
  },
  "안심귀가 이동 모드가 시작되었습니다.": {
    "en": "Safe Return tracking has started.",
    "ja": "安心帰宅モードを開始しました。",
    "zh": "安全回家模式已开始。",
    "fr": "Le mode Retour sécurisé a démarré.",
    "pt": "O modo Volta segura foi iniciado."
  },
  "안전산행 모드가 시작되었습니다. GPS 경로는 데이터 통신이 없어도 계속 기록됩니다.": {
    "en": "Safe Hiking has started. GPS route recording continues without mobile data.",
    "ja": "安全登山モードを開始しました。GPS経路はデータ通信がなくても記録を続けます。",
    "zh": "安全徒步模式已开始。即使没有数据网络，GPS 轨迹仍会继续记录。",
    "fr": "Le mode Randonnée sûre a démarré. La trace GPS continue même sans données mobiles.",
    "pt": "O modo Trilha segura foi iniciado. O trajeto GPS continua sendo registrado mesmo sem dados móveis."
  },
  "안전산행 GPS 기록이 시작되었습니다. 현재 서버 통신이 원활하지 않아 공유는 지연될 수 있습니다.": {
    "en": "Safe Hiking GPS recording has started. Sharing may be delayed because server connectivity is unstable.",
    "ja": "安全登山のGPS記録を開始しました。現在サーバー通信が不安定なため、共有が遅れる場合があります。",
    "zh": "安全徒步 GPS 记录已开始。当前服务器连接不畅，共享可能延迟。",
    "fr": "L’enregistrement GPS de randonnée a démarré. La connexion au serveur est instable, le partage peut être retardé.",
    "pt": "O registro GPS da trilha começou. A conexão com o servidor está instável e o compartilhamento pode atrasar."
  },
  "위치 추적은 시작되었습니다. 내비게이션을 사용하려면 먼저 목적지를 선택해 주세요.": {
    "en": "Location tracking has started. Select a destination first to use navigation.",
    "ja": "位置追跡は開始されました。ナビゲーションを使うには先に目的地を選択してください。",
    "zh": "位置追踪已开始。要使用导航，请先选择目的地。",
    "fr": "Le suivi de position a commencé. Sélectionnez d’abord une destination pour utiliser la navigation.",
    "pt": "O rastreamento de localização começou. Selecione primeiro um destino para usar a navegação."
  },
  "내비게이션 앱을 사용할 수 없습니다.": {
    "en": "Navigation app is unavailable.",
    "ja": "ナビゲーションアプリを使用できません。",
    "zh": "导航应用不可用。",
    "fr": "L’application de navigation n’est pas disponible.",
    "pt": "O aplicativo de navegação não está disponível."
  },
  "내비게이션 앱을 열 수 없습니다.": {
    "en": "Unable to open the navigation app.",
    "ja": "ナビゲーションアプリを開けません。",
    "zh": "无法打开导航应用。",
    "fr": "Impossible d’ouvrir l’application de navigation.",
    "pt": "Não foi possível abrir o aplicativo de navegação."
  },
  "내비게이션 실행 중 오류가 발생했습니다.": {
    "en": "Failed to launch navigation.",
    "ja": "ナビゲーション起動中にエラーが発生しました。",
    "zh": "启动导航时发生错误。",
    "fr": "Une erreur est survenue au lancement de la navigation.",
    "pt": "Ocorreu um erro ao iniciar a navegação."
  },
  "화면 추적은 종료되었습니다. 서버 종료 기록은 네트워크 연결 후 다시 반영됩니다.": {
    "en": "On-screen tracking has stopped. The server end record will sync after network connectivity returns.",
    "ja": "画面上の追跡は終了しました。サーバーの終了記録はネットワーク接続後に反映されます。",
    "zh": "屏幕追踪已结束。服务器的结束记录将在网络恢复后同步。",
    "fr": "Le suivi à l’écran est terminé. La fin de session sera synchronisée avec le serveur après reconnexion.",
    "pt": "O rastreamento na tela foi encerrado. O término será sincronizado com o servidor quando a rede voltar."
  },
  "안전 모드가 종료되었습니다.": {
    "en": "Safety tracking has stopped.",
    "ja": "安全モードを終了しました。",
    "zh": "安全模式已结束。",
    "fr": "Le mode de sécurité est terminé.",
    "pt": "O modo de segurança foi encerrado."
  },
  "먼저 현재 위치를 확인해 주세요.": {
    "en": "Check your current location first.",
    "ja": "先に現在地を確認してください。",
    "zh": "请先确认当前位置。",
    "fr": "Vérifiez d’abord votre position actuelle.",
    "pt": "Verifique primeiro sua localização atual."
  },
  "오프라인 안전 정보를 복사했습니다.": {
    "en": "Offline safety information copied.",
    "ja": "オフライン安全情報をコピーしました。",
    "zh": "已复制离线安全信息。",
    "fr": "Informations de sécurité hors ligne copiées.",
    "pt": "Informações de segurança offline copiadas."
  },
  "산행 시작 후 출발점이 자동 저장됩니다.": {
    "en": "The start point is saved when hiking begins.",
    "ja": "登山開始後に出発点が自動保存されます。",
    "zh": "开始徒步后将自动保存起点。",
    "fr": "Le point de départ est enregistré automatiquement au début de la randonnée.",
    "pt": "O ponto de partida é salvo automaticamente ao iniciar a trilha."
  },
  "로그인 후 보호자를 설정할 수 있습니다.": {
    "en": "Sign in to set a guardian.",
    "ja": "ログイン後に保護者を設定できます。",
    "zh": "登录后可设置监护人。",
    "fr": "Connectez-vous pour définir un proche de confiance.",
    "pt": "Faça login para definir um responsável."
  },
  "보호자 설정": {
    "en": "People & groups",
    "ja": "連絡先・グループ",
    "zh": "联系人与分组",
    "fr": "Proches et groupes",
    "pt": "Pessoas e grupos"
  },
  "보호자 이름": {
    "en": "Guardian name",
    "ja": "保護者名",
    "zh": "监护人姓名",
    "fr": "Nom du proche",
    "pt": "Nome do responsável"
  },
  "보호자 연락처": {
    "en": "Guardian contact",
    "ja": "保護者連絡先",
    "zh": "监护人联系方式",
    "fr": "Contact du proche",
    "pt": "Contato do responsável"
  },
  "전화번호 또는 이메일": {
    "en": "Phone number or email",
    "ja": "電話番号またはメール",
    "zh": "电话号码或电子邮件",
    "fr": "Téléphone ou e-mail",
    "pt": "Telefone ou e-mail"
  },
  "보호자 정보는 안전산행 세션에만 연결되며, 산행 위치 공유를 시작할 때 함께 기록됩니다.": {
    "en": "Guardian details are linked to Safe Hiking and recorded with the hiking session when sharing starts.",
    "ja": "保護者情報は安全登山セッションにのみ関連付けられ、位置共有開始時に記録されます。",
    "zh": "监护人信息仅关联安全徒步会话，并在开始位置共享时记录。",
    "fr": "Les informations du proche sont liées uniquement à la session de randonnée et enregistrées au démarrage du partage.",
    "pt": "Os dados do responsável ficam ligados apenas à sessão de trilha e são registrados ao iniciar o compartilhamento."
  },
  "이름과 연락처를 모두 입력해 주세요.": {
    "en": "Enter both name and contact.",
    "ja": "名前と連絡先を入力してください。",
    "zh": "请输入姓名和联系方式。",
    "fr": "Saisissez le nom et le contact.",
    "pt": "Informe nome e contato."
  },
  "보호자 설정을 저장했습니다.": {
    "en": "Guardian setup saved.",
    "ja": "保護者設定を保存しました。",
    "zh": "监护人设置已保存。",
    "fr": "Configuration du proche enregistrée.",
    "pt": "Configuração do responsável salva."
  },
  "보호자 정보는 현재 화면에 저장되었습니다. 네트워크 연결 후 서버 저장을 다시 시도해 주세요.": {
    "en": "Guardian details are kept on this screen. Try saving again after network connectivity returns.",
    "ja": "保護者情報は現在の画面に保持されています。通信復旧後に再度保存してください。",
    "zh": "监护人信息已保留在当前页面。网络恢复后请再次保存。",
    "fr": "Les informations restent sur cet écran. Réessayez de les enregistrer après le retour du réseau.",
    "pt": "Os dados ficaram nesta tela. Tente salvar novamente quando a conexão voltar."
  },
  "미설정": {
    "en": "Not set",
    "ja": "未設定",
    "zh": "未设置",
    "fr": "Non défini",
    "pt": "Não definido"
  },
  "오늘": {
    "en": "Today",
    "ja": "今日",
    "zh": "今天",
    "fr": "Aujourd’hui",
    "pt": "Hoje"
  },
  "귀환 예정시간은 현재 시각 이후로 설정해 주세요.": {
    "en": "Set the planned return time after the current time.",
    "ja": "帰還予定時刻は現在時刻より後に設定してください。",
    "zh": "请将预计返回时间设置为当前时间之后。",
    "fr": "Définissez une heure de retour postérieure à l’heure actuelle.",
    "pt": "Defina o horário de retorno para depois do horário atual."
  },
  "귀환 예정시간을 설정했습니다:": {
    "en": "Planned return time set:",
    "ja": "帰還予定時刻を設定しました：",
    "zh": "已设置预计返回时间：",
    "fr": "Heure de retour prévue définie :",
    "pt": "Horário de retorno definido:"
  },
  "현재 위치:": {
    "en": "Current location:",
    "ja": "現在地：",
    "zh": "当前位置：",
    "fr": "Position actuelle :",
    "pt": "Localização atual:"
  },
  "진행 중인 안전산행이 없습니다.": {
    "en": "There is no active Safe Hiking session.",
    "ja": "進行中の安全登山はありません。",
    "zh": "没有正在进行的安全徒步。",
    "fr": "Aucune randonnée sûre n’est en cours.",
    "pt": "Não há trilha segura em andamento."
  },
  "안전하게 하산했습니다": {
    "en": "I Arrived Safely",
    "ja": "無事に下山しました",
    "zh": "已安全下山",
    "fr": "Je suis redescendu en sécurité",
    "pt": "Desci com segurança"
  },
  "산행을 안전하게 마쳤습니까? 확인하면 위치 공유와 GPS 세션이 함께 종료되고 안전 하산 상태가 기록됩니다.": {
    "en": "Did you finish the hike safely? Confirming stops location sharing and GPS tracking and records a safe completion.",
    "ja": "登山を安全に終えましたか？確認すると位置共有とGPSセッションが終了し、安全下山として記録されます。",
    "zh": "您已安全结束徒步吗？确认后将停止位置共享和 GPS 会话，并记录安全下山状态。",
    "fr": "Avez-vous terminé la randonnée en sécurité ? La confirmation arrête le partage et le GPS et enregistre une arrivée sûre.",
    "pt": "Terminou a trilha com segurança? A confirmação encerra o compartilhamento e o GPS e registra a chegada segura."
  },
  "안전 하산 확인": {
    "en": "Confirm Safe Arrival",
    "ja": "安全下山を確認",
    "zh": "确认安全下山",
    "fr": "Confirmer l’arrivée sûre",
    "pt": "Confirmar chegada segura"
  },
  "안전 하산으로 기록하고 산행을 종료했습니다.": {
    "en": "Safe arrival recorded and the hiking session has ended.",
    "ja": "安全下山として記録し、登山を終了しました。",
    "zh": "已记录安全下山并结束徒步。",
    "fr": "Arrivée sûre enregistrée et randonnée terminée.",
    "pt": "Chegada segura registrada e trilha encerrada."
  },
  "산행 종료까지 위치 공유가 시작되었습니다.": {
    "en": "Location sharing is active until the hike ends.",
    "ja": "登山終了までの位置共有を開始しました。",
    "zh": "已开始位置共享至徒步结束。",
    "fr": "Le partage jusqu’à la fin de la randonnée a commencé.",
    "pt": "O compartilhamento até o fim da trilha começou."
  },
  "보호자 변경": {
    "en": "Change recipients",
    "ja": "共有相手を変更",
    "zh": "更改共享对象",
    "fr": "Modifier les destinataires",
    "pt": "Alterar destinatários"
  },
  "귀환 예정시간": {
    "en": "Return Time",
    "ja": "帰還予定時刻",
    "zh": "预计返回时间",
    "fr": "Heure de retour prévue",
    "pt": "Horário de retorno"
  },
  "공유 중": {
    "en": "Sharing",
    "ja": "共有中",
    "zh": "正在共享",
    "fr": "Partage actif",
    "pt": "Compartilhando"
  },
  "산행 종료까지 공유": {
    "en": "Share Until Hike Ends",
    "ja": "登山終了まで共有",
    "zh": "共享至徒步结束",
    "fr": "Jusqu’à la fin",
    "pt": "Até o fim da trilha"
  },
  "산행 안전 계획": {
    "en": "Hiking Safety Plan",
    "ja": "登山安全計画",
    "zh": "徒步安全计划",
    "fr": "Plan de sécurité randonnée",
    "pt": "Plano de segurança da trilha"
  },
  "위치 공유 중": {
    "en": "Sharing active",
    "ja": "位置共有中",
    "zh": "正在共享位置",
    "fr": "Partage de position actif",
    "pt": "Compartilhamento ativo"
  },
  "공유 대기": {
    "en": "Share ready",
    "ja": "共有待機",
    "zh": "等待共享",
    "fr": "Prêt à partager",
    "pt": "Pronto para compartilhar"
  },
  "공유 방식": {
    "en": "Sharing Mode",
    "ja": "共有方式",
    "zh": "共享方式",
    "fr": "Mode de partage",
    "pt": "Modo de compartilhamento"
  },
  "산행 종료까지": {
    "en": "Until hike ends",
    "ja": "登山終了まで",
    "zh": "直到徒步结束",
    "fr": "Jusqu’à la fin",
    "pt": "Até o fim"
  },
  "사용자 시작 대기": {
    "en": "Waiting to start",
    "ja": "ユーザー開始待ち",
    "zh": "等待用户启动",
    "fr": "En attente du démarrage",
    "pt": "Aguardando início"
  },
  "산행 종료 시 ‘안전하게 하산했습니다’를 누르면 위치 공유와 GPS 추적이 함께 종료되고 안전 하산 상태가 기록됩니다.": {
    "en": "At the end of the hike, tap “I Arrived Safely” to stop location sharing and GPS tracking together and record a safe completion.",
    "ja": "登山終了時に「無事に下山しました」を押すと、位置共有とGPS追跡が終了し、安全下山として記録されます。",
    "zh": "徒步结束时点击“已安全下山”，位置共享和 GPS 跟踪将同时结束，并记录安全下山状态。",
    "fr": "À la fin, appuyez sur « Je suis redescendu en sécurité » pour arrêter le partage et le GPS et enregistrer une arrivée sûre.",
    "pt": "Ao terminar, toque em “Desci com segurança” para encerrar o compartilhamento e o GPS e registrar a chegada segura."
  },
  "안전산행은 보호자와 귀환 예정시간을 설정한 뒤 ‘산행 시작’을 누를 수 있습니다. 위치 공유는 산행 종료까지 유지되며, 데이터 통신이 끊겨도 기기 GPS 경로 기록은 계속됩니다. 하산 후에는 ‘안전하게 하산했습니다’를 눌러 종료하세요.": {
    "en": "In Safe Hiking, set a guardian and planned return time, then start the hike. Location sharing can stay active until the hike ends, while device GPS route recording continues even if data disconnects. Tap “I Arrived Safely” after descending.",
    "ja": "安全登山では保護者と帰還予定時刻を設定してから「登山開始」を押します。位置共有は登山終了まで維持でき、通信が切れても端末のGPS経路記録は続きます。下山後は「無事に下山しました」で終了してください。",
    "zh": "安全徒步中先设置监护人和预计返回时间，再点击“开始徒步”。位置共享可持续到徒步结束，即使断网设备 GPS 轨迹仍会记录。下山后点击“已安全下山”结束。",
    "fr": "Pour la randonnée sûre, définissez un proche et l’heure de retour, puis démarrez. Le partage peut rester actif jusqu’à la fin et la trace GPS continue même sans données. Après la descente, appuyez sur « Je suis redescendu en sécurité ».",
    "pt": "Na Trilha Segura, defina o responsável e o horário de retorno e depois inicie. O compartilhamento pode continuar até o fim e o GPS segue registrando sem dados móveis. Ao descer, toque em “Desci com segurança”."
  },
  "산행 출발점": {
    "en": "Hiking start point",
    "ja": "登山出発点",
    "zh": "徒步起点",
    "fr": "Point de départ",
    "pt": "Ponto de partida"
  },
  "출발점을 귀환 기준점으로 설정했습니다. 청록색으로 기록된 실제 이동 경로를 참고하세요.": {
    "en": "The hiking start point is now the return reference. Follow the recorded cyan breadcrumb route.",
    "ja": "出発点を帰還基準点に設定しました。シアンで記録された実際の移動経路を参考にしてください。",
    "zh": "已将起点设为返回参考点。请参考青色记录的实际移动轨迹。",
    "fr": "Le point de départ est défini comme repère de retour. Suivez la trace réelle enregistrée en cyan.",
    "pt": "O ponto de partida foi definido como referência de retorno. Use o trajeto real registrado em ciano."
  },
  "안심귀가 기능": {
    "en": "Safe Return",
    "ja": "安心帰宅機能",
    "zh": "安全回家功能",
    "fr": "Retour sécurisé",
    "pt": "Volta segura"
  },
  "안전산행 기능": {
    "en": "Safe Hiking",
    "ja": "安全登山機能",
    "zh": "安全徒步功能",
    "fr": "Randonnée sûre",
    "pt": "Trilha segura"
  },
  "이동 중": {
    "en": "Moving",
    "ja": "移動中",
    "zh": "移动中",
    "fr": "En déplacement",
    "pt": "Em movimento"
  },
  "산행 중": {
    "en": "Hiking",
    "ja": "登山中",
    "zh": "徒步中",
    "fr": "En randonnée",
    "pt": "Em trilha"
  },
  "경로 기록 중": {
    "en": "Recording Route",
    "ja": "経路記録中",
    "zh": "正在记录轨迹",
    "fr": "Trace en cours",
    "pt": "Registrando trajeto"
  },
  "경로 기록": {
    "en": "Record Route",
    "ja": "経路記録",
    "zh": "记录轨迹",
    "fr": "Enregistrer la trace",
    "pt": "Registrar trajeto"
  },
  "장시간 정지 감지": {
    "en": "Long Stop Detection",
    "ja": "長時間停止検知",
    "zh": "长时间静止检测",
    "fr": "Détection d’arrêt prolongé",
    "pt": "Detecção de parada prolongada"
  },
  "경로 이탈 알림": {
    "en": "Route Deviation Alert",
    "ja": "経路逸脱アラート",
    "zh": "偏离路线提醒",
    "fr": "Alerte de déviation",
    "pt": "Alerta de desvio de rota"
  },
  "오프라인 안전 정보": {
    "en": "Offline Safety",
    "ja": "オフライン安全情報",
    "zh": "离线安全信息",
    "fr": "Sécurité hors ligne",
    "pt": "Segurança offline"
  },
  "오프라인 지도 저장": {
    "en": "Save Offline Map",
    "ja": "オフライン地図を保存",
    "zh": "保存离线地图",
    "fr": "Enregistrer la carte hors ligne",
    "pt": "Salvar mapa offline"
  },
  "산행 전 오프라인 지도 준비": {
    "en": "Prepare Offline Map Before Hiking",
    "ja": "登山前にオフライン地図を準備",
    "zh": "徒步前准备离线地图",
    "fr": "Préparer la carte hors ligne avant la randonnée",
    "pt": "Preparar mapa offline antes da trilha"
  },
  "지도 저장됨": {
    "en": "Map saved",
    "ja": "地図保存済み",
    "zh": "地图已保存",
    "fr": "Carte enregistrée",
    "pt": "Mapa salvo"
  },
  "산행 전 저장 필요": {
    "en": "Save before hiking",
    "ja": "登山前に保存してください",
    "zh": "徒步前请保存",
    "fr": "À enregistrer avant la randonnée",
    "pt": "Salve antes da trilha"
  },
  "Chrome에서는 위치와 화면을 확인할 수 있습니다. 실제 오프라인 지도 저장은 휴대폰 앱에서 실행하세요.": {
    "en": "Chrome can be used to check the screen and location. Save the actual offline map in the mobile app.",
    "ja": "Chromeでは位置と画面を確認できます。実際のオフライン地図保存はスマートフォンアプリで実行してください。",
    "zh": "Chrome 可用于查看位置和界面。实际离线地图保存请在手机应用中执行。",
    "fr": "Chrome permet de vérifier la position et l’écran. Enregistrez réellement la carte hors ligne dans l’application mobile.",
    "pt": "No Chrome, você pode verificar a localização e a tela. Salve o mapa offline de fato no aplicativo móvel."
  },
  "인터넷이 연결된 곳에서 필요한 산행 구간을 지도에 보이게 한 뒤 아래 버튼을 누르세요. 현재 보이는 범위가 휴대폰에 저장됩니다.": {
    "en": "While online, frame the hiking area you need on the map, then tap the button below. The visible area is saved on your phone.",
    "ja": "通信できる場所で必要な登山範囲を地図に表示し、下のボタンを押してください。現在表示中の範囲がスマートフォンに保存されます。",
    "zh": "在有网络的地方将需要的徒步区域显示在地图上，然后点击下方按钮。当前可见范围会保存到手机。",
    "fr": "Avec Internet disponible, cadrez la zone de randonnée nécessaire puis appuyez sur le bouton ci-dessous. La zone visible est enregistrée sur le téléphone.",
    "pt": "Com Internet disponível, enquadre no mapa a área necessária da trilha e toque no botão abaixo. A área visível será salva no celular."
  },
  "저장 완료: 인터넷이 끊기면 저장 지도 위에 현재 GPS, 청록색 이동경로, 출발점이 계속 표시됩니다.": {
    "en": "Saved: if Internet disconnects, current GPS, the cyan route, and the start point continue to appear over the saved map.",
    "ja": "保存完了：通信が切れても保存地図の上に現在のGPS、シアンの移動経路、出発点が表示され続けます。",
    "zh": "保存完成：断网后，当前 GPS、青绿色移动轨迹和起点仍会继续显示在已保存地图上。",
    "fr": "Enregistrement terminé : sans Internet, le GPS actuel, la trace cyan et le point de départ restent affichés sur la carte enregistrée.",
    "pt": "Salvo: sem Internet, o GPS atual, o trajeto ciano e o ponto inicial continuam aparecendo sobre o mapa salvo."
  },
  "저장 지도": {
    "en": "Saved Map",
    "ja": "保存地図",
    "zh": "已保存地图",
    "fr": "Carte enregistrée",
    "pt": "Mapa salvo"
  },
  "지도 미저장": {
    "en": "Map not saved",
    "ja": "地図未保存",
    "zh": "地图未保存",
    "fr": "Carte non enregistrée",
    "pt": "Mapa não salvo"
  },
  "지도 저장 중...": {
    "en": "Saving map...",
    "ja": "地図を保存中...",
    "zh": "正在保存地图...",
    "fr": "Enregistrement de la carte...",
    "pt": "Salvando mapa..."
  },
  "현재 지도 저장": {
    "en": "Save Visible Map",
    "ja": "現在の地図を保存",
    "zh": "保存当前地图",
    "fr": "Enregistrer la carte visible",
    "pt": "Salvar mapa visível"
  },
  "저장 지도 삭제": {
    "en": "Delete Saved Map",
    "ja": "保存地図を削除",
    "zh": "删除已保存地图",
    "fr": "Supprimer la carte enregistrée",
    "pt": "Excluir mapa salvo"
  },
  "오프라인 지도 저장은 모바일 앱에서 사용할 수 있습니다.": {
    "en": "Offline map saving is available in the mobile app.",
    "ja": "オフライン地図の保存はモバイルアプリで利用できます。",
    "zh": "离线地图保存可在移动应用中使用。",
    "fr": "L’enregistrement hors ligne est disponible dans l’application mobile.",
    "pt": "O salvamento de mapa offline está disponível no app móvel."
  },
  "지도 화면을 아직 저장할 수 없습니다. 잠시 후 다시 눌러주세요.": {
    "en": "The map is not ready to save yet. Try again shortly.",
    "ja": "まだ地図画面を保存できません。少し待ってもう一度お試しください。",
    "zh": "地图画面尚未准备好保存，请稍后重试。",
    "fr": "La carte n’est pas encore prête à être enregistrée. Réessayez dans un instant.",
    "pt": "O mapa ainda não está pronto para salvar. Tente novamente em instantes."
  },
  "지도 이미지 저장에 실패했습니다.": {
    "en": "Failed to save the map image.",
    "ja": "地図画像の保存に失敗しました。",
    "zh": "地图图像保存失败。",
    "fr": "Échec de l’enregistrement de l’image de la carte.",
    "pt": "Falha ao salvar a imagem do mapa."
  },
  "오프라인 지도 저장에 실패했습니다.": {
    "en": "Failed to save the offline map.",
    "ja": "オフライン地図の保存に失敗しました。",
    "zh": "离线地图保存失败。",
    "fr": "Échec de l’enregistrement de la carte hors ligne.",
    "pt": "Falha ao salvar o mapa offline."
  },
  "현재 보이는 지도를 오프라인 안전지도로 저장했습니다.": {
    "en": "The visible map was saved for offline safety use.",
    "ja": "現在表示中の地図をオフライン安全地図として保存しました。",
    "zh": "当前可见地图已保存为离线安全地图。",
    "fr": "La carte visible a été enregistrée comme carte de sécurité hors ligne.",
    "pt": "O mapa visível foi salvo como mapa de segurança offline."
  },
  "오프라인 지도 저장 중 오류가 발생했습니다.": {
    "en": "An error occurred while saving the offline map.",
    "ja": "オフライン地図の保存中にエラーが発生しました。",
    "zh": "保存离线地图时发生错误。",
    "fr": "Une erreur est survenue lors de l’enregistrement hors ligne.",
    "pt": "Ocorreu um erro ao salvar o mapa offline."
  },
  "저장된 오프라인 지도를 삭제했습니다.": {
    "en": "The saved offline map was deleted.",
    "ja": "保存済みのオフライン地図を削除しました。",
    "zh": "已删除保存的离线地图。",
    "fr": "La carte hors ligne enregistrée a été supprimée.",
    "pt": "O mapa offline salvo foi excluído."
  },
  "저장 지도 + 청록색 GPS 이동경로": {
    "en": "Saved map + cyan GPS breadcrumb",
    "ja": "保存地図 + シアンのGPS経路",
    "zh": "已保存地图 + 青绿色 GPS 轨迹",
    "fr": "Carte enregistrée + trace GPS cyan",
    "pt": "Mapa salvo + trilha GPS ciano"
  },
  "산행 전에 지도를 원하는 범위로 이동·확대/축소한 뒤 ‘현재 지도 저장’을 누르세요. 저장된 지도는 앱 기기에 남아 인터넷이 끊겨도 배경으로 표시되고, 그 위에 현재 GPS·청록색 이동경로·출발점이 계속 갱신됩니다. 주소검색·원격 공유·SOS 서버 전달은 통신 복구 전까지 지연될 수 있습니다.": {
    "en": "Before hiking, pan and zoom to the area you need and tap “Save Visible Map”. The saved map remains on the device and is shown offline while current GPS, the cyan breadcrumb, and the start point keep updating above it. Address search, remote sharing, and SOS server delivery may wait for connectivity to return.",
    "ja": "登山前に必要な範囲へ地図を移動・拡大縮小し、「現在の地図を保存」を押してください。保存地図は端末に残り、通信が切れても背景として表示され、その上で現在のGPS・シアンの移動経路・出発点が更新され続けます。住所検索・遠隔共有・SOSサーバー送信は通信復旧まで遅れる場合があります。",
    "zh": "徒步前请将地图移动并缩放到所需范围，然后点击“保存当前地图”。保存的地图会保留在设备上，即使断网也可作为背景显示，其上会继续更新当前 GPS、青绿色轨迹和起点。地址搜索、远程共享和 SOS 服务器发送可能延迟到网络恢复。",
    "fr": "Avant la randonnée, cadrez et zoomez la zone voulue puis touchez « Enregistrer la carte visible ». La carte reste sur l’appareil et s’affiche sans Internet ; le GPS actuel, la trace cyan et le point de départ continuent de se mettre à jour par-dessus. La recherche d’adresse, le partage distant et l’envoi SOS peuvent attendre le retour du réseau.",
    "pt": "Antes da trilha, ajuste e amplie a área desejada e toque em “Salvar mapa visível”. O mapa permanece no aparelho e aparece sem Internet; GPS atual, trilha ciano e ponto inicial continuam sendo atualizados por cima. Busca de endereço, compartilhamento remoto e envio SOS podem aguardar a conexão voltar."
  },
  "GPS 사용": {
    "en": "GPS READY",
    "ja": "GPS使用可能",
    "zh": "GPS 可用",
    "fr": "GPS ACTIF",
    "pt": "GPS ATIVO"
  },
  "현재 좌표": {
    "en": "Coordinates",
    "ja": "現在座標",
    "zh": "当前坐标",
    "fr": "Coordonnées",
    "pt": "Coordenadas"
  },
  "GPS 오차": {
    "en": "GPS Accuracy",
    "ja": "GPS誤差",
    "zh": "GPS 误差",
    "fr": "Précision GPS",
    "pt": "Erro GPS"
  },
  "기록 거리": {
    "en": "Recorded",
    "ja": "記録距離",
    "zh": "记录距离",
    "fr": "Distance enregistrée",
    "pt": "Distância registrada"
  },
  "출발점 방향": {
    "en": "Start Point",
    "ja": "出発点方向",
    "zh": "起点方向",
    "fr": "Direction du départ",
    "pt": "Direção do início"
  },
  "경과 시간": {
    "en": "Elapsed",
    "ja": "経過時間",
    "zh": "经过时间",
    "fr": "Temps écoulé",
    "pt": "Tempo decorrido"
  },
  "출발점 귀환": {
    "en": "Return to Start",
    "ja": "出発点へ戻る",
    "zh": "返回起点",
    "fr": "Retour au départ",
    "pt": "Voltar ao início"
  },
  "안전정보 복사": {
    "en": "Copy Safety Info",
    "ja": "安全情報をコピー",
    "zh": "复制安全信息",
    "fr": "Copier les infos de sécurité",
    "pt": "Copiar informações de segurança"
  },
  "위치 확인 중": {
    "en": "Locating...",
    "ja": "位置確認中",
    "zh": "正在定位",
    "fr": "Localisation...",
    "pt": "Localizando..."
  },
  "내 위치": {
    "en": "My Location",
    "ja": "現在地",
    "zh": "我的位置",
    "fr": "Ma position",
    "pt": "Minha localização"
  },
  "등록 중": {
    "en": "Registering...",
    "ja": "登録中",
    "zh": "正在登记",
    "fr": "Enregistrement...",
    "pt": "Cadastrando..."
  },
  "장소 등록": {
    "en": "Register Place",
    "ja": "場所登録",
    "zh": "登记地点",
    "fr": "Ajouter un lieu",
    "pt": "Cadastrar local"
  },
  "목적지 등록": {
    "en": "Set Destination",
    "ja": "目的地登録",
    "zh": "设置目的地",
    "fr": "Définir la destination",
    "pt": "Definir destino"
  },
  "목적지 변경": {
    "en": "Change Destination",
    "ja": "目的地変更",
    "zh": "更改目的地",
    "fr": "Changer la destination",
    "pt": "Alterar destino"
  },
  "30분 위치 공유": {
    "en": "Share Location 30 min",
    "ja": "30分位置共有",
    "zh": "共享位置30分钟",
    "fr": "Partager 30 min",
    "pt": "Compartilhar por 30 min"
  },
  "긴급 SOS": {
    "en": "Emergency SOS",
    "ja": "緊急SOS",
    "zh": "紧急 SOS",
    "fr": "SOS urgence",
    "pt": "SOS de emergência"
  },
  "사용법: ‘내 위치’로 GPS 위치를 확인하고, ‘장소 등록’으로 경기장을 신청합니다. ‘30분 위치 공유’와 ‘긴급 SOS’는 기존 방식 그대로 작동합니다.": {
    "en": "How to use: check your GPS with My Location and request a field with Register Place. 30-minute sharing and Emergency SOS work as before.",
    "ja": "使い方：「現在地」でGPS位置を確認し、「場所登録」でフィールドを申請します。「30分位置共有」と「緊急SOS」は従来どおり動作します。",
    "zh": "使用方法：通过“我的位置”确认 GPS 位置，通过“登记地点”申请场地。“共享位置30分钟”和“紧急 SOS”按原方式运行。",
    "fr": "Utilisation : vérifiez votre position GPS avec « Ma position » et proposez un terrain avec « Ajouter un lieu ». Le partage 30 min et le SOS fonctionnent comme auparavant.",
    "pt": "Como usar: confirme o GPS em “Minha localização” e solicite um campo em “Cadastrar local”. O compartilhamento por 30 min e o SOS funcionam como antes."
  },
  "지도에서 원하는 지점을 누르거나 ‘목적지 등록’을 눌러 목적지를 지정할 수 있습니다. 위치 기능은 사용자가 직접 시작해야만 작동하며, 긴급 시에는 ‘긴급 SOS’를 사용하세요.": {
    "en": "Tap a point on the map or Set Destination. Location features run only when you start them; use Emergency SOS when needed.",
    "ja": "地図上の地点をタップするか「目的地登録」で目的地を指定できます。位置機能はユーザーが自分で開始した場合のみ動作し、緊急時は「緊急SOS」を使用してください。",
    "zh": "可在地图上点击地点或点击“设置目的地”来指定目的地。定位功能仅在用户主动启动后运行，紧急时请使用“紧急 SOS”。",
    "fr": "Touchez un point sur la carte ou « Définir la destination ». Les fonctions de position ne démarrent que sur votre action ; en urgence, utilisez « SOS urgence ».",
    "pt": "Toque em um ponto no mapa ou em “Definir destino”. Os recursos de localização só funcionam quando iniciados pelo usuário; em emergência, use “SOS de emergência”."
  },
  "선택한 지점이 목적지로 등록되었습니다.": {
    "en": "The selected point was set as the destination.",
    "ja": "選択した地点を目的地に設定しました。",
    "zh": "所选地点已设为目的地。",
    "fr": "Le point sélectionné a été défini comme destination.",
    "pt": "O ponto selecionado foi definido como destino."
  },
  "경기장 정보를 불러오지 못했습니다:": {
    "en": "Could not load field information:",
    "ja": "フィールド情報を読み込めませんでした:",
    "zh": "无法加载场地信息：",
    "fr": "Impossible de charger les terrains :",
    "pt": "Não foi possível carregar os campos:"
  },
  "등록된 경기장이 없습니다. “경기장 등록”으로 첫 장소를 추가하세요.": {
    "en": "No registered fields yet. Add the first place with Field Registration.",
    "ja": "登録済みのフィールドがありません。「フィールド登録」で最初の場所を追加してください。",
    "zh": "暂无已登记场地。请通过“场地登记”添加第一个地点。",
    "fr": "Aucun terrain enregistré. Ajoutez le premier avec « Enregistrer un terrain ».",
    "pt": "Nenhum campo cadastrado. Adicione o primeiro em “Cadastrar campo”."
  },
  "청록색 = 실제 GPS 이동경로": {
    "en": "Cyan = recorded GPS breadcrumb",
    "ja": "シアン＝実際のGPS移動経路",
    "zh": "青色 = 实际 GPS 移动轨迹",
    "fr": "Cyan = trace GPS réelle",
    "pt": "Ciano = trajeto GPS real"
  },
  "주소 정보 없음": {
    "en": "No address information",
    "ja": "住所情報なし",
    "zh": "无地址信息",
    "fr": "Adresse indisponible",
    "pt": "Endereço indisponível"
  },
  "이 경기장으로 길찾기": {
    "en": "Directions to this Field",
    "ja": "このフィールドへの道順",
    "zh": "导航到此场地",
    "fr": "Itinéraire vers ce terrain",
    "pt": "Rota para este campo"
  },
  "저장": {
    "en": "Save",
    "ja": "保存",
    "zh": "保存",
    "fr": "Enregistrer",
    "pt": "Salvar"
  },
  "안심동행 · 로그인 / 계정": {
    "en": "Safe Companion · Sign in / Account",
    "ja": "安心同行・ログイン／アカウント",
    "zh": "安心同行 · 登录／账户",
    "fr": "Compagnon sécurité · Connexion / Compte",
    "pt": "Companhia segura · Entrar / Conta"
  },
  "한 걸음의 설렘부터\n집으로 돌아오는 순간까지.": {
    "en": "From the first step\nto arriving safely home.",
    "ja": "最初の一歩から\n無事に家へ帰るまで。",
    "zh": "从迈出第一步\n到平安回家的那一刻。",
    "fr": "Du premier pas\nau retour à la maison.",
    "pt": "Do primeiro passo\naté voltar para casa."
  },
  "위치 공유는 이동 화면에서 시작·중지할 수 있습니다. 계정 관리 후 이동 상태와 공유 상태를 확인하세요.": {
    "en": "Start or stop sharing on the trip screen. After managing your account, check your trip and sharing status.",
    "ja": "位置共有は移動画面で開始・停止できます。アカウント操作後は移動と共有の状態をご確認ください。",
    "zh": "可在行程页面开始或停止位置共享。账户操作后请检查行程与共享状态。",
    "fr": "Activez ou arrêtez le partage sur l’écran du trajet. Après une opération sur le compte, vérifiez le trajet et le partage.",
    "pt": "Inicie ou pare o compartilhamento na tela do percurso. Após gerenciar a conta, confira o percurso e o compartilhamento."
  },
  "로그인 → 내 위치 확인 → 목적지 선택 → 귀가 시작. 승인된 보호자와 공유하려면 위치 공유를 켜주세요.": {
    "en": "Sign in → Check your location → Choose a destination → Start your return. Enable location sharing for approved contacts.",
    "ja": "ログイン → 現在地を確認 → 目的地を選択 → 帰宅開始。承認済みの保護者と共有するには位置共有を有効にしてください。",
    "zh": "登录 → 确认当前位置 → 选择目的地 → 开始回家。若要与已批准的联系人共享，请开启位置共享。",
    "fr": "Connexion → Position → Destination → Départ du retour. Activez le partage pour vos proches autorisés.",
    "pt": "Entrar → Conferir localização → Escolher destino → Iniciar volta. Ative o compartilhamento para contatos aprovados."
  },
  "로그인 → 내 위치 확인 → 산행 시작. 승인된 보호자와 공유하려면 위치 공유를 켜주세요.": {
    "en": "Sign in → Check your location → Start hiking. Enable location sharing for approved contacts.",
    "ja": "ログイン → 現在地を確認 → 登山開始。承認済みの保護者と共有するには位置共有を有効にしてください。",
    "zh": "登录 → 确认当前位置 → 开始徒步。若要与已批准的联系人共享，请开启位置共享。",
    "fr": "Connexion → Position → Début de randonnée. Activez le partage pour vos proches autorisés.",
    "pt": "Entrar → Conferir localização → Iniciar trilha. Ative o compartilhamento para contatos aprovados."
  },
  "서버 위치 저장 • 활성 (전달·수신 확인과 다름)": {
    "en": "Server location upload • Active (delivery is not confirmed)",
    "ja": "サーバーへの位置保存・有効（相手への到達確認ではありません）",
    "zh": "服务器位置上传 · 已启用（不代表对方已接收）",
    "fr": "Envoi de position • Actif (réception non confirmée)",
    "pt": "Envio da localização • Ativo (recebimento não confirmado)"
  },
  "서버 위치 공유 • 비활성": {
    "en": "Server location sharing • Inactive",
    "ja": "サーバー位置共有・無効",
    "zh": "服务器位置共享 · 未启用",
    "fr": "Partage de position • Inactif",
    "pt": "Compartilhamento no servidor • Inativo"
  },
  "개인 이동 기록은 본인 계정에 저장됩니다. 별도로 승인한 보호자는 위치 공유 중 현재 위치와 최근 경로를 볼 수 있습니다. 아래 문자·메신저 버튼은 현재 좌표를 직접 보내는 기능입니다.": {
    "en": "Personal trip records are saved to your account. Approved contacts can view your location and recent route while sharing is active. The message buttons below send a snapshot of your coordinates.",
    "ja": "個人の移動記録は自分のアカウントに保存されます。承認した保護者は共有中の位置と最近の経路を確認できます。下のメッセージボタンは、その時点の座標を直接送る機能です。",
    "zh": "个人行程记录保存在本人账户中。已批准的联系人可在共享期间查看位置和最近路线。下方短信与消息按钮发送的是当时坐标。",
    "fr": "Les trajets personnels sont enregistrés dans votre compte. Les proches autorisés voient votre position et le trajet récent pendant le partage. Les boutons de messagerie envoient un instantané des coordonnées.",
    "pt": "Registros pessoais ficam na sua conta. Contatos aprovados veem a posição e a rota recente durante o compartilhamento. Os botões de mensagem enviam as coordenadas daquele momento."
  },
  "보호자에게 현재 위치 직접 보내기": {
    "en": "Send current coordinates to a contact",
    "ja": "保護者に現在地を直接送る",
    "zh": "直接向联系人发送当前位置",
    "fr": "Envoyer les coordonnées au proche",
    "pt": "Enviar coordenadas ao contato"
  },
  "산행 종료": {
    "en": "End hike",
    "ja": "登山を終了",
    "zh": "结束徒步",
    "fr": "Terminer la randonnée",
    "pt": "Encerrar trilha"
  },
  "{mode} 시작": {
    "en": "Start {mode}",
    "ja": "{mode}を開始",
    "zh": "开始{mode}",
    "fr": "Démarrer : {mode}",
    "pt": "Iniciar: {mode}"
  },
  "{mode} 기록 • 시작 대기": {
    "en": "{mode} record • Ready to start",
    "ja": "{mode}の記録・開始待ち",
    "zh": "{mode}记录 · 等待开始",
    "fr": "Relevé {mode} · Prêt à démarrer",
    "pt": "Registro {mode} · Aguardando início"
  },
  "{mode} 기록 • 진행 중": {
    "en": "{mode} record • In progress",
    "ja": "{mode}の記録・記録中",
    "zh": "{mode}记录 · 进行中",
    "fr": "Relevé {mode} · En cours",
    "pt": "Registro {mode} · Em andamento"
  },
  "보호자: {name} • 자동 알림 미지원": {
    "en": "Recipients: {name} • No automatic alerts",
    "ja": "共有相手：{name}・自動通知なし",
    "zh": "共享对象：{name} · 无自动通知",
    "fr": "Destinataires : {name} · Pas d’alerte automatique",
    "pt": "Destinatários: {name} · Sem alerta automático"
  },
  "마지막 서버 수신: {time}": {
    "en": "Last server receipt: {time}",
    "ja": "最終サーバー受信：{time}",
    "zh": "服务器最后接收：{time}",
    "fr": "Dernière réception serveur : {time}",
    "pt": "Último recebimento no servidor: {time}"
  },
  "로그인 / 계정": {
    "en": "Sign in / Account",
    "ja": "ログイン／アカウント",
    "zh": "登录／账户",
    "fr": "Connexion / Compte",
    "pt": "Entrar / Conta"
  },
  "보호자 연결 · 위치 확인": {
    "en": "Contacts · Location",
    "ja": "保護者連携・位置確認",
    "zh": "联系人连接 · 位置查看",
    "fr": "Contacts · Position",
    "pt": "Contatos · Localização"
  },
  "사용설명서": {
    "en": "User guide",
    "ja": "使い方ガイド",
    "zh": "使用说明",
    "fr": "Guide d’utilisation",
    "pt": "Guia de uso"
  },
  "비밀번호를 입력해주세요.": {
    "en": "Enter your password.",
    "ja": "パスワードを入力してください。",
    "zh": "请输入密码。",
    "fr": "Saisissez votre mot de passe.",
    "pt": "Digite sua senha."
  },
  "8자 이상 입력해주세요.": {
    "en": "Enter at least 8 characters.",
    "ja": "8文字以上で入力してください。",
    "zh": "请输入至少8个字符。",
    "fr": "Saisissez au moins 8 caractères.",
    "pt": "Digite pelo menos 8 caracteres."
  },
  "이미 가입된 이메일입니다. 로그인 또는 비밀번호 재설정을 이용하세요.": {
    "en": "This email is registered. Sign in or reset your password.",
    "ja": "登録済みのメールです。ログインまたはパスワード再設定をご利用ください。",
    "zh": "该邮箱已注册，请登录或重设密码。",
    "fr": "Cet e-mail est déjà inscrit. Connectez-vous ou réinitialisez le mot de passe.",
    "pt": "Este e-mail já está cadastrado. Entre ou redefina a senha."
  },
  "시도가 너무 많습니다. 잠시 후 다시 시도하세요.": {
    "en": "Too many attempts. Try again later.",
    "ja": "試行回数が多すぎます。しばらくして再試行してください。",
    "zh": "尝试次数过多，请稍后再试。",
    "fr": "Trop de tentatives. Réessayez plus tard.",
    "pt": "Muitas tentativas. Tente novamente mais tarde."
  },
  "처리하지 못했습니다. 인터넷 연결과 서버 접근 권한을 확인하세요. 삭제 실패 시 계정은 유지됩니다.": {
    "en": "The action failed. Check your connection and server access. Your account is kept if deletion fails.",
    "ja": "処理できませんでした。通信とサーバー権限を確認してください。削除失敗時はアカウントを保持します。",
    "zh": "操作失败，请检查网络及服务器权限。删除失败时账户会保留。",
    "fr": "Échec de l’opération. Vérifiez la connexion et les droits serveur. Le compte est conservé si la suppression échoue.",
    "pt": "A operação falhou. Confira a conexão e as permissões. A conta é mantida se a exclusão falhar."
  },
  "오르큐브 회원": {
    "en": "ORQUBE member",
    "ja": "ORQUBE会員",
    "zh": "ORQUBE会员",
    "fr": "Membre ORQUBE",
    "pt": "Membro ORQUBE"
  },
  "회원가입 전에 개인정보 처리 안내 확인에 동의해주세요.": {
    "en": "Read and accept the privacy information before signing up.",
    "ja": "登録前に個人情報の取扱いを確認し同意してください。",
    "zh": "注册前请阅读并同意隐私信息说明。",
    "fr": "Lisez et acceptez les informations de confidentialité avant l’inscription.",
    "pt": "Leia e aceite as informações de privacidade antes de se cadastrar."
  },
  "재설정 안내를 받을 이메일을 입력해주세요.": {
    "en": "Enter your email to receive reset instructions.",
    "ja": "再設定案内を受け取るメールを入力してください。",
    "zh": "请输入接收重设说明的邮箱。",
    "fr": "Saisissez l’e-mail pour recevoir les instructions.",
    "pt": "Digite o e-mail para receber as instruções."
  },
  "가입된 이메일이면 비밀번호 재설정 메일을 확인해주세요.": {
    "en": "If the email is registered, check for a password reset message.",
    "ja": "登録済みの場合はパスワード再設定メールをご確認ください。",
    "zh": "若该邮箱已注册，请查看密码重设邮件。",
    "fr": "Si cet e-mail est inscrit, consultez le message de réinitialisation.",
    "pt": "Se o e-mail estiver cadastrado, confira a mensagem de redefinição."
  },
  "이메일 인증 완료. 이동 화면에서 위치 공유를 시작할 수 있습니다.": {
    "en": "Email verified. You can start sharing on the trip screen.",
    "ja": "メール認証済みです。移動画面で位置共有を開始できます。",
    "zh": "邮箱已验证，可在行程页面开始位置共享。",
    "fr": "E-mail vérifié. Vous pouvez partager depuis le trajet.",
    "pt": "E-mail verificado. Você pode compartilhar na tela do percurso."
  },
  "아직 미인증 상태입니다. 받은 메일의 인증 링크를 먼저 눌러주세요.": {
    "en": "Email is not verified yet. Open the verification link first.",
    "ja": "未認証です。受信したメールの認証リンクを開いてください。",
    "zh": "邮箱尚未验证，请先打开邮件中的验证链接。",
    "fr": "E-mail non vérifié. Ouvrez d’abord le lien de vérification.",
    "pt": "E-mail ainda não verificado. Abra primeiro o link de verificação."
  },
  "로그아웃되었습니다. 이 기기의 저장 지도와 화면 기록을 지웠습니다.": {
    "en": "Signed out. Saved map and on-screen records were cleared.",
    "ja": "ログアウトしました。保存地図と画面の記録を消去しました。",
    "zh": "已退出登录，并清除了保存地图与页面记录。",
    "fr": "Déconnexion effectuée. La carte et les données à l’écran ont été effacées.",
    "pt": "Saiu da conta. O mapa salvo e os registros da tela foram limpos."
  },
  "취소했습니다.": {
    "en": "Cancelled.",
    "ja": "キャンセルしました。",
    "zh": "已取消。",
    "fr": "Annulé.",
    "pt": "Cancelado."
  },
  "산행 기록을 삭제했습니다.": {
    "en": "Hiking records deleted.",
    "ja": "登山記録を削除しました。",
    "zh": "徒步记录已删除。",
    "fr": "Relevés de randonnée supprimés.",
    "pt": "Registros de trilha excluídos."
  },
  "처리하지 못했습니다. 이메일 인증·연결 승인·서버 규칙과 인터넷을 확인하세요.": {
    "en": "Action failed. Check email verification, contact approval, server rules and your connection.",
    "ja": "処理失敗。メール認証・連携承認・サーバールール・通信をご確認ください。",
    "zh": "操作失败，请检查邮箱验证、连接批准、服务器规则及网络。",
    "fr": "Échec. Vérifiez l’e-mail, l’autorisation du contact, les règles serveur et la connexion.",
    "pt": "Falha. Confira verificação de e-mail, aprovação, regras do servidor e conexão."
  },
  "공유가 종료·만료되었거나 연결 승인이 없습니다. 통신 상태도 확인하세요.": {
    "en": "Sharing ended, expired or is not approved. Also check the connection.",
    "ja": "共有の終了・期限切れ、または未承認です。通信状態も確認してください。",
    "zh": "共享已结束、已过期或未获批准。也请检查网络。",
    "fr": "Partage terminé, expiré ou non autorisé. Vérifiez aussi la connexion.",
    "pt": "Compartilhamento encerrado, expirado ou não aprovado. Confira também a conexão."
  },
  "요청을 보냈습니다. 상대방이 내 ID를 확인하고 승인해야 합니다.": {
    "en": "Request sent. The other person must verify and approve your ID.",
    "ja": "リクエストを送りました。相手によるID確認と承認が必要です。",
    "zh": "请求已发送，对方须核对并批准您的ID。",
    "fr": "Demande envoyée. Le proche doit vérifier et approuver votre ID.",
    "pt": "Solicitação enviada. A outra pessoa deve conferir e aprovar seu ID."
  },
  "수색 참고자료 조회가 만료되었습니다.": {
    "en": "Search reference access has expired.",
    "ja": "捜索参考資料の閲覧期限が切れました。",
    "zh": "搜寻参考资料查看权限已过期。",
    "fr": "Accès au dossier de recherche expiré.",
    "pt": "O acesso aos dados de busca expirou."
  },
  "저장된 산행 기록이 없습니다.": {
    "en": "No saved hiking record.",
    "ja": "保存された登山記録はありません。",
    "zh": "暂无已保存的徒步记录。",
    "fr": "Aucune randonnée enregistrée.",
    "pt": "Nenhum registro de trilha salvo."
  },
  "공유된 수색 참고자료가 없거나 만료되었습니다.": {
    "en": "No shared search reference, or it has expired.",
    "ja": "共有された捜索資料がないか、期限切れです。",
    "zh": "无共享的搜寻资料或资料已过期。",
    "fr": "Aucun dossier partagé, ou dossier expiré.",
    "pt": "Não há dados de busca compartilhados ou eles expiraram."
  },
  "접근 권한 또는 통신을 확인하세요.": {
    "en": "Check access permission and connection.",
    "ja": "アクセス権限と通信をご確認ください。",
    "zh": "请检查访问权限和网络。",
    "fr": "Vérifiez l’autorisation et la connexion.",
    "pt": "Confira a permissão de acesso e a conexão."
  },
  "파일 공유 실패 · 요약 복사를 이용하세요.": {
    "en": "File sharing failed · Copy the summary instead.",
    "ja": "ファイル共有失敗・要約のコピーをご利用ください。",
    "zh": "文件共享失败 · 请复制摘要。",
    "fr": "Échec du partage de fichier · Copiez le résumé.",
    "pt": "Falha ao compartilhar arquivo · Copie o resumo."
  },
  "서버 삭제가 완료되어야 기기 기록도 삭제합니다. 이미 내보낸 파일은 삭제되지 않습니다.": {
    "en": "Device records are deleted after server deletion succeeds. Exported files are not deleted.",
    "ja": "サーバー削除完了後に端末記録を削除します。書き出し済みファイルは削除されません。",
    "zh": "服务器删除成功后才会删除设备记录。已导出的文件不会删除。",
    "fr": "Les données locales sont supprimées après celles du serveur. Les fichiers exportés restent.",
    "pt": "Os registros locais são excluídos após a exclusão no servidor. Arquivos exportados permanecem."
  },
  "서버 삭제 대기 · 인터넷 연결 후 재시도하세요.": {
    "en": "Server deletion pending · Retry when connected.",
    "ja": "サーバー削除待ち・接続後に再試行してください。",
    "zh": "等待服务器删除 · 联网后请重试。",
    "fr": "Suppression serveur en attente · Réessayez en ligne.",
    "pt": "Exclusão no servidor pendente · Tente novamente com conexão."
  },
  "먼저 산행 또는 귀가 시작을 눌러 주세요.": {
    "en": "Start a hike or return trip first.",
    "ja": "先に登山または帰宅を開始してください。",
    "zh": "请先开始徒步或回家行程。",
    "fr": "Démarrez d’abord la randonnée ou le retour.",
    "pt": "Inicie primeiro a trilha ou a volta."
  },
  "기기 위치 공유를 종료했습니다. 오프라인이면 서버 종료 반영이 지연될 수 있습니다.": {
    "en": "Location sharing stopped on this device. Offline server updates may be delayed.",
    "ja": "端末の位置共有を停止しました。オフラインではサーバーへの反映が遅れる場合があります。",
    "zh": "设备位置共享已停止。离线时服务器更新可能延迟。",
    "fr": "Partage arrêté sur cet appareil. Hors ligne, l’arrêt côté serveur peut être retardé.",
    "pt": "Compartilhamento parado no aparelho. Offline, a atualização no servidor pode atrasar."
  },
  "기록을 이어갑니다. 중단된 시간은 기록되지 않으며 위치 공유는 다시 동의해야 합니다.": {
    "en": "Recording resumed. The interrupted period has no records. Sharing requires consent again.",
    "ja": "記録を再開します。中断中の記録はなく、共有には再同意が必要です。",
    "zh": "已继续记录。中断期间没有记录，共享需重新同意。",
    "fr": "Enregistrement repris. La période interrompue n’est pas enregistrée. Le partage nécessite un nouveau consentement.",
    "pt": "Registro retomado. O período interrompido não foi registrado. Compartilhar exige novo consentimento."
  },
  "이전 기록을 이어가거나 새 산행을 시작할 수 있습니다. 새 산행은 이 기기의 이전 기록을 교체합니다. 필요한 경로를 먼저 내보내세요.": {
    "en": "Resume the saved trip or start a new hike. A new hike replaces the previous device record. Export any needed route first.",
    "ja": "保存記録の再開または新しい登山を選べます。新しい登山は端末の以前の記録を置き換えます。必要な経路は先に書き出してください。",
    "zh": "可继续已存记录或开始新徒步。新徒步会替换设备上的旧记录，请先导出所需路线。",
    "fr": "Reprenez le trajet enregistré ou démarrez une randonnée. Une nouvelle randonnée remplace les données locales précédentes. Exportez d’abord le parcours utile.",
    "pt": "Retome o registro salvo ou inicie nova trilha. A nova trilha substitui o registro local anterior. Exporte antes a rota necessária."
  },
  "보호자에게 위치 보내기": {
    "en": "Send location to contact",
    "ja": "保護者に位置を送る",
    "zh": "向联系人发送位置",
    "fr": "Envoyer la position au proche",
    "pt": "Enviar localização ao contato"
  },
  "현재 좌표를 담은 메시지입니다. 실시간 추적 링크가 아닙니다. 수신자를 확인한 후 직접 전송하세요.": {
    "en": "This message contains coordinates at this moment, not a live tracking link. Check the recipient and send it yourself.",
    "ja": "このメッセージは現在の座標です。リアルタイム追跡リンクではありません。宛先を確認して自分で送信してください。",
    "zh": "消息包含此刻的坐标，并非实时跟踪链接。请核对收件人后自行发送。",
    "fr": "Ce message contient les coordonnées du moment, pas un lien de suivi en direct. Vérifiez le destinataire et envoyez-le.",
    "pt": "A mensagem contém as coordenadas do momento, não um link ao vivo. Confira o destinatário e envie."
  },
  "위치 문구를 복사했습니다. 카카오톡 또는 문자에 붙여넣고 직접 보내세요.": {
    "en": "Location text copied. Paste into KakaoTalk or SMS and send.",
    "ja": "位置文をコピーしました。KakaoTalkやSMSに貼り付けて送信してください。",
    "zh": "位置文本已复制，请粘贴到KakaoTalk或短信中发送。",
    "fr": "Texte copié. Collez-le dans KakaoTalk ou un SMS et envoyez.",
    "pt": "Texto copiado. Cole no KakaoTalk ou SMS e envie."
  },
  "복사하지 못했습니다. 위 문구를 선택해 직접 복사하세요.": {
    "en": "Copy failed. Select and copy the text above.",
    "ja": "コピー失敗。上の文章を選択してコピーしてください。",
    "zh": "复制失败，请选择并复制上方文本。",
    "fr": "Échec de la copie. Sélectionnez et copiez le texte ci-dessus.",
    "pt": "Falha ao copiar. Selecione e copie o texto acima."
  },
  "문구 복사 · 카카오톡에 붙여넣기": {
    "en": "Copy text · Paste into KakaoTalk",
    "ja": "文をコピー・KakaoTalkに貼り付け",
    "zh": "复制文本 · 粘贴到KakaoTalk",
    "fr": "Copier · Coller dans KakaoTalk",
    "pt": "Copiar · Colar no KakaoTalk"
  },
  "문자 앱을 열지 못했습니다. 문구 복사를 이용하세요.": {
    "en": "Could not open SMS. Copy the text instead.",
    "ja": "SMSを開けませんでした。文のコピーをご利用ください。",
    "zh": "无法打开短信，请复制文本。",
    "fr": "Impossible d’ouvrir les SMS. Copiez le texte.",
    "pt": "Não foi possível abrir SMS. Copie o texto."
  },
  "문자 작성 요청을 보냈습니다. 수신 번호와 내용을 확인하고 직접 전송하세요.": {
    "en": "SMS composition requested. Check the number and message, then send.",
    "ja": "SMS作成を要求しました。宛先と内容を確認して送信してください。",
    "zh": "已请求编写短信，请核对号码和内容后自行发送。",
    "fr": "Rédaction du SMS demandée. Vérifiez le numéro et le message avant l’envoi.",
    "pt": "Composição do SMS solicitada. Confira o número e o texto antes de enviar."
  },
  "이 기기에서 문자 앱을 열 수 없습니다. 문구 복사를 이용하세요.": {
    "en": "SMS is unavailable on this device. Copy the text.",
    "ja": "この端末ではSMSを開けません。文をコピーしてください。",
    "zh": "此设备无法打开短信，请复制文本。",
    "fr": "Les SMS sont indisponibles sur cet appareil. Copiez le texte.",
    "pt": "SMS indisponível neste aparelho. Copie o texto."
  },
  "문자로 보내기 · 휴대전화": {
    "en": "Send by SMS · Phone",
    "ja": "SMSで送信・携帯電話",
    "zh": "短信发送 · 手机",
    "fr": "Envoyer par SMS · Téléphone",
    "pt": "Enviar por SMS · Celular"
  },
  "공유 화면에서 수신자를 선택해 전송하세요. 앱은 전달 완료를 확인하지 않습니다.": {
    "en": "Choose the recipient in the share sheet and send. The app does not confirm delivery.",
    "ja": "共有画面で宛先を選んで送信してください。アプリは到達を確認しません。",
    "zh": "请在共享面板选择接收人并发送，应用不会确认送达。",
    "fr": "Choisissez le destinataire dans le partage puis envoyez. La réception n’est pas confirmée par l’application.",
    "pt": "Escolha o destinatário no compartilhamento e envie. O app não confirma a entrega."
  },
  "공유 화면을 열지 못했습니다. 문구 복사를 이용하세요.": {
    "en": "Could not open sharing. Copy the text.",
    "ja": "共有画面を開けませんでした。文をコピーしてください。",
    "zh": "无法打开共享面板，请复制文本。",
    "fr": "Impossible d’ouvrir le partage. Copiez le texte.",
    "pt": "Não foi possível abrir o compartilhamento. Copie o texto."
  },
  "카카오톡 등으로 공유 · 앱 선택": {
    "en": "Share with KakaoTalk etc. · Choose app",
    "ja": "KakaoTalkなどで共有・アプリを選択",
    "zh": "通过KakaoTalk等共享 · 选择应用",
    "fr": "Partager via KakaoTalk, etc. · Choisir une application",
    "pt": "Compartilhar via KakaoTalk etc. · Escolher app"
  },
  "카카오톡 공유 버튼은 기기의 일반 공유 화면을 엽니다. 카카오톡 설치 여부에 따라 목록에 표시됩니다. PC에서 공유 목록이 비면 문구 복사를 이용하세요. 전송한 메시지는 산행 종료 후에도 수신자에게 남습니다.": {
    "en": "This button opens the device share sheet. KakaoTalk appears if supported and installed. If the desktop list is empty, copy the text. Sent messages remain with recipients after the hike.",
    "ja": "このボタンは端末の共有画面を開きます。KakaoTalkは対応・インストール状況により表示されます。PCで一覧が空なら文をコピーしてください。送信済みメッセージは登山終了後も相手に残ります。",
    "zh": "此按钮打开设备共享面板。KakaoTalk是否出现取决于安装与支持情况。电脑列表为空时请复制文本。徒步结束后，已发消息仍保留在接收人处。",
    "fr": "Ce bouton ouvre le partage de l’appareil. KakaoTalk apparaît selon sa disponibilité. Sur ordinateur, copiez le texte si la liste est vide. Les messages envoyés restent chez les destinataires après la randonnée.",
    "pt": "O botão abre o compartilhamento do aparelho. KakaoTalk aparece se instalado e compatível. No computador, copie o texto se a lista estiver vazia. Mensagens enviadas permanecem com os destinatários após a trilha."
  },
  "01 · 안전산행이 돕는 일": {
    "en": "01 · How Safe Hiking helps",
    "ja": "01・安全登山でできること",
    "zh": "01 · 安全徒步能做什么",
    "fr": "01 · L’utilité de la randonnée sûre",
    "pt": "01 · Como a trilha segura ajuda"
  },
  "안심귀가는 목적지까지의 이동에, 안전산행은 산행 경로와 귀환 계획 및 통신두절 전 기록에 초점을 둡니다. 안전산행은 ① 기기 우선 경로 저장 ② 통신 복구 후 재전송 ③ 별도 동의한 보호자의 마지막 기록 조회 ④ 수색 참고자료 내보내기를 제공합니다. 이 기록은 수색 범위를 검토하는 참고자료이며 실종자의 현재 위치를 확정하거나 구조 접수를 보장하지 않습니다.": {
    "en": "Safe Return focuses on reaching a destination. Safe Hiking focuses on the hiking route, return plan and observations before connection loss. Its four tools are device-first recording, retry after reconnection, separately consented last-record access for approved contacts, and export for search reference. These observations can inform a search area; they do not establish a missing person’s current position or confirm rescue dispatch.",
    "ja": "安心帰宅は目的地への移動、安全登山は登山経路・帰還計画・通信途絶前の記録を重視します。端末優先の経路保存、接続回復後の再送、別途同意した保護者の最終記録閲覧、捜索参考資料の書き出しを提供します。捜索範囲の検討に使う参考資料であり、行方不明者の現在地や救助受付を保証しません。",
    "zh": "安全回家侧重到达目的地，安全徒步侧重徒步路线、返回计划和断网前的记录。四项工具是设备优先保存、恢复网络后重传、单独同意的联系人查看最后记录、导出搜寻参考资料。记录可辅助判断搜寻范围，但不能确定失踪者的当前位置，也不保证救援受理。",
    "fr": "Le retour sécurisé vise l’arrivée à destination. La randonnée sûre privilégie le parcours, le retour prévu et les observations avant une coupure. Ses quatre outils : enregistrement local prioritaire, nouvel envoi après reconnexion, consultation du dernier relevé avec consentement distinct et export pour la recherche. Ces données aident à examiner une zone de recherche, sans établir la position actuelle ni garantir une intervention.",
    "pt": "A volta segura acompanha a chegada ao destino. A trilha segura prioriza rota, retorno previsto e registros anteriores à perda de conexão. Oferece gravação local, reenvio após reconexão, acesso ao último registro com consentimento separado e exportação para busca. Esses dados ajudam a avaliar uma área de busca, sem determinar a posição atual nem garantir atendimento de resgate."
  },
  "02 · 출발 전 설정과 보호자 승인": {
    "en": "02 · Before departure and contact approval",
    "ja": "02・出発前の設定と保護者承認",
    "zh": "02 · 出发前设置与联系人批准",
    "fr": "02 · Préparation et autorisation du proche",
    "pt": "02 · Preparação e aprovação do contato"
  },
  "산행자와 보호자는 서로 다른 계정으로 로그인하고 이메일 인증을 완료합니다. 보호자가 산행자의 연결 ID로 요청하면 산행자는 직접 전달받은 ID인지 확인해 승인합니다. 안전산행에서 내 위치를 확인하고 보호자 연락처와 귀환 예정시간을 설정한 후 산행을 시작하세요. 연락처 입력만으로 연결이 승인되거나 문자·자동 알림이 발송되지는 않습니다. 날짜와 시각, 위치 권한, 배터리 및 GPS 수신 상태도 확인하세요.": {
    "en": "In People & groups, add a person with a display name, relationship and connection ID. The recipient verifies the ID and accepts the invitation. Connecting alone never shares location. Choose recipients and start sharing in Hiking, Safe Return or Location Sharing. Each person keeps private names and relationships. Phone numbers alone cannot locate anyone.",
    "ja": "連絡先・グループで名前・家族や友人などの関係・接続IDを入力して招待します。相手がIDを確認して承認します。連携だけで位置は公開されません。登山・帰宅・位置共有で相手を選んで開始してください。名前と関係はそれぞれの一覧で管理し、電話番号だけでは位置を調べません。",
    "zh": "在联系人与分组中输入显示名、家人朋友等关系及连接ID发送邀请，对方核对ID后接受。连接不会自动共享位置，须在徒步、回家或位置共享中选择对象并开始。双方各自管理显示名和关系，无法仅凭电话号码定位。",
    "fr": "Dans Proches et groupes, invitez avec nom, relation et ID. Le destinataire vérifie l’ID et accepte. La connexion seule ne partage jamais la position : choisissez les destinataires et démarrez depuis randonnée, retour ou localisation. Chacun gère ses noms et relations privés. Un numéro seul ne permet pas de localiser.",
    "pt": "Em Pessoas e grupos, convide com nome, relação e ID. O destinatário confere o ID e aceita. Conectar não compartilha posição automaticamente: escolha pessoas e inicie na trilha, volta ou localização. Cada um gerencia nomes e relações privados. Telefone sozinho não localiza ninguém."
  },
  "03 · 경로를 휴대폰에 먼저 저장": {
    "en": "03 · Save the route on the device first",
    "ja": "03・まず端末に経路を保存",
    "zh": "03 · 优先保存在设备上",
    "fr": "03 · Enregistrer d’abord sur l’appareil",
    "pt": "03 · Salvar primeiro no aparelho"
  },
  "산행 중 GPS 관측점의 위도·경도·실제 관측시각과 가능한 정확도·고도를 기기에 저장합니다. 약 5m 이동하거나 관측 사이 15초가 지나면 저장하며 같은 관측시각은 중복 기록하지 않습니다. 계정별로 이 기기의 최근 산행 한 건과 최대 최근 10,000점을 유지합니다. 초과한 앞부분은 삭제 건수로 표시합니다. 새 산행은 이전 기기 기록을 교체하므로 필요한 자료를 먼저 내보내세요. 정확도가 낮은 GPS 관측에는 실제 이동과 다른 오차가 포함될 수 있습니다.": {
    "en": "During a hike, the device saves latitude, longitude, actual GPS observation time, and available accuracy and altitude. A point is retained after about 5 metres of movement or 15 seconds between observations; duplicate observation times are ignored. Each account keeps one latest hike and up to 10,000 recent points on this device. Earlier excess points are counted as discarded. A new hike replaces this record, so export needed data first. Poor GPS accuracy can produce positions different from actual movement.",
    "ja": "登山中、緯度・経度・実際のGPS観測時刻、取得可能な精度・高度を端末に保存します。約5m移動または観測間隔15秒で記録し、同じ観測時刻は重複保存しません。端末にはアカウントごとの最新登山1件・直近最大10,000点を保持し、超過した古い点は削除数で示します。新しい登山は記録を置き換えるため、必要な資料を先に書き出してください。GPS精度が低いと実際と異なる位置が含まれます。",
    "zh": "徒步中在设备保存经纬度、实际GPS观测时间，以及可用的精度和海拔。移动约5米或两次观测间隔达15秒时保存，重复观测时间不重复记录。每个账户在此设备保留最近一次徒步及最多最近10,000点，超出部分的旧点会被删除并显示数量。新徒步会替换旧记录，请先导出所需资料。GPS精度差时记录可能偏离实际移动。",
    "fr": "L’appareil conserve latitude, longitude, heure réelle du relevé GPS, précision et altitude disponibles. Un point est gardé après environ 5 m ou 15 s entre relevés ; les heures identiques sont ignorées. Chaque compte conserve sur cet appareil sa dernière randonnée et au plus 10 000 points récents. Les anciens points excédentaires sont comptés comme supprimés. Exportez avant une nouvelle randonnée, qui remplace ce relevé. Un GPS imprécis peut déformer le déplacement.",
    "pt": "O aparelho salva latitude, longitude, horário real do GPS e precisão e altitude disponíveis. Guarda um ponto após cerca de 5 metros ou 15 segundos entre observações; horários duplicados são ignorados. Cada conta mantém neste aparelho a última trilha e até 10.000 pontos recentes. Pontos antigos excedentes são descartados e contados. Exporte o necessário antes de uma nova trilha, que substitui o registro. GPS impreciso pode distorcer o movimento."
  },
  "04 · 통신두절 중 가능한 일과 지도": {
    "en": "04 · Connection loss and saved maps",
    "ja": "04・通信途絶中の動作と保存地図",
    "zh": "04 · 断网期间与保存地图",
    "fr": "04 · Coupure réseau et cartes enregistrées",
    "pt": "04 · Perda de conexão e mapas salvos"
  },
  "휴대전화의 위치 서비스와 GPS가 작동하고 앱이 계속 실행되면 데이터 통신이 없어도 기기에 경로를 기록할 수 있습니다. 그러나 새 좌표를 보호자에게 보내거나 온라인 주소 검색·길찾기를 할 수는 없습니다. 산행 전에 필요한 지역을 화면에 맞춘 뒤 지도 저장을 이용하세요. 저장 지도는 그 화면 영역의 이미지이며 전국 오프라인 지도나 모든 확대 단계의 지도 타일이 아닙니다. 앱 강제 종료·절전 제한·권한 철회·GPS 수신 불량 중에는 새 기록이 중단될 수 있습니다.": {
    "en": "With location services and GPS working and the app running, device recording can continue without mobile data. New coordinates cannot reach contacts, and online address search and routing are unavailable. Before departure, frame the needed area and save the visible map. This is an image of that area, not a nationwide offline map or every zoom-level tile. Force-closing, power restrictions, withdrawn permissions or poor GPS reception can interrupt new observations.",
    "ja": "位置サービス・GPSが動作しアプリが実行中なら、データ通信がなくても端末記録を続けられます。ただし保護者への新座標送信やオンライン住所検索・経路検索はできません。出発前に必要な範囲を表示して地図を保存してください。保存地図は画面範囲の画像で、全国対応のオフライン地図や全ズームのタイルではありません。強制終了・省電力制限・権限解除・GPS不良で記録が止まる場合があります。",
    "zh": "位置服务和GPS正常且应用持续运行时，即使没有移动数据也可在设备记录。但不能向联系人传送新坐标，在线地址搜索和导航也不可用。出发前将所需区域置于画面内并保存地图。保存的是该范围的图片，并非全国离线地图或所有缩放级别的地图瓦片。强制关闭、省电限制、撤销权限或GPS接收不良可能中断记录。",
    "fr": "Si le GPS et la localisation fonctionnent et que l’application tourne, l’enregistrement local peut continuer sans données mobiles. Aucune nouvelle position ne peut atteindre les proches ; recherche d’adresse et itinéraires en ligne sont indisponibles. Avant de partir, cadrez la zone utile et enregistrez la carte visible. C’est une image, pas une carte hors ligne nationale ni toutes les tuiles de zoom. Arrêt forcé, économie d’énergie, retrait de permission ou mauvais GPS peuvent interrompre les relevés.",
    "pt": "Com GPS e localização funcionando e o app aberto, o registro local pode continuar sem dados móveis. Novas coordenadas não chegam aos contatos; busca de endereço e rotas online ficam indisponíveis. Antes de sair, enquadre a área necessária e salve o mapa visível. É uma imagem, não um mapa offline nacional nem todos os níveis de zoom. Encerramento forçado, economia de energia, retirada de permissão ou GPS ruim podem interromper o registro."
  },
  "05 · 연결 복구 후 재전송": {
    "en": "05 · Retry after reconnection",
    "ja": "05・接続回復後の再送",
    "zh": "05 · 恢复连接后重传",
    "fr": "05 · Nouvel envoi après reconnexion",
    "pt": "05 · Reenvio após reconexão"
  },
  "수색자료 공유에 별도 동의하면 전송 대기 상태를 기기에 보관합니다. 앱이 실행되는 동안 약 20초마다 서버 반영을 재시도하고, 다시 로그인한 뒤에도 남은 대기 작업을 확인합니다. 보호자용 서버 경로는 용량을 줄이기 위해 최대 4,000점을 균등 추출하며 시작점과 마지막 점을 포함합니다. 마지막 GPS 관측시각과 마지막 서버 수신시각은 서로 다릅니다. 오래된 좌표를 늦게 전송해도 GPS 관측시각이 새 시각으로 바뀌지 않습니다. 전송 대기 상태가 계속되면 인터넷·이메일 인증·서버 권한을 확인하고 재시도를 누르세요.": {
    "en": "With separate consent for search records, pending uploads are retained locally. While the app runs, it retries about every 20 seconds; signing in again also checks pending work. The server route evenly samples up to 4,000 points, including first and last, to reduce size. GPS observation time differs from server receipt time. Sending an old fix later does not change when GPS observed it. If pending continues, check connectivity, verified email and server permissions, then retry.",
    "ja": "捜索資料の共有に別途同意すると、送信待ち状態を端末に保持します。実行中は約20秒ごとに再試行し、再ログイン後も残った処理を確認します。容量を抑えるためサーバー経路は最初と最後を含む最大4,000点を均等抽出します。GPS観測時刻とサーバー受信時刻は異なります。古い座標を後から送っても観測時刻は新しくなりません。待機が続く場合は通信・メール認証・権限を確認して再試行してください。",
    "zh": "单独同意搜寻资料共享后，待上传状态保存在设备。应用运行时约每20秒重试，重新登录后也检查未完成任务。为减少体积，服务器路线均匀抽取最多4,000点，包含首末点。GPS观测时间与服务器接收时间不同，延迟上传旧坐标不会改变其实际观测时间。若持续等待，请检查网络、邮箱验证和服务器权限并重试。",
    "fr": "Avec un consentement distinct, les envois en attente sont gardés localement. L’application réessaie environ toutes les 20 s pendant son exécution ; une reconnexion au compte vérifie aussi les tâches restantes. Le parcours serveur est échantillonné uniformément à 4 000 points maximum, extrémités incluses. Heure GPS et réception serveur diffèrent : un envoi tardif ne rajeunit pas le relevé. En cas d’attente persistante, vérifiez réseau, e-mail et permissions, puis réessayez.",
    "pt": "Com consentimento separado, os envios pendentes ficam no aparelho. O app tenta novamente a cada cerca de 20 segundos enquanto executa e verifica pendências ao entrar na conta. A rota no servidor usa até 4.000 pontos uniformemente amostrados, incluindo início e fim. Horário do GPS e recebimento no servidor são diferentes: envio atrasado não torna o registro recente. Se continuar pendente, confira rede, e-mail verificado e permissões, e tente de novo."
  },
  "06 · 실시간 지도와 마지막 기록 구분": {
    "en": "06 · Live map versus last record",
    "ja": "06・現在地マップと最終記録の違い",
    "zh": "06 · 实时地图与最后记录的区别",
    "fr": "06 · Carte en direct et dernier relevé",
    "pt": "06 · Mapa ao vivo e último registro"
  },
  "실시간 지도는 이동 중 약 5초·정지 시 약 15초 전송을 목표로 하며 실제 주기는 GPS·통신·절전 상태에 따라 달라집니다. 파란 선은 최근 최대 500점이고 마커는 수신한 좌표 사이에서만 움직입니다. 20초 이상 지연되면 마지막 위치로 표시하며 약 2분 뒤 실시간 조회가 만료됩니다. 별도 수색자료 화면의 주황 경로는 마지막으로 기록·수신된 관측점입니다. 날짜와 GPS 시각을 먼저 읽고 현재 위치라고 단정하지 마세요. 점 사이 직선은 실제 등산로나 기록이 없는 구간을 복원한 경로가 아닙니다.": {
    "en": "The live map targets updates about every 5 seconds moving and 15 seconds stationary; GPS, network and power settings affect this. Blue shows up to 500 recent points. The marker moves only between received fixes. After over 20 seconds without updates it shows a delayed last position; live access expires after about 2 minutes. Orange in the separate search screen shows recorded observations. Read the date and GPS time first; do not treat it as current location. Straight lines do not reconstruct trails or missing intervals.",
    "ja": "現在地マップは移動中約5秒・停止中約15秒を目標に送信しますが、GPS・通信・省電力で変わります。青線は直近最大500点で、マーカーは受信済み座標の間だけ動きます。20秒超の遅延を表示し、約2分後に現在地閲覧が失効します。別の捜索画面のオレンジ線は記録された観測点です。日付とGPS時刻を先に読み、現在地と断定しないでください。点間の直線は登山道や欠測区間の復元ではありません。",
    "zh": "实时地图目标为移动时约5秒、静止时约15秒更新，实际取决于GPS、网络和省电设置。蓝线显示最近最多500点，标记只在已接收坐标间移动。超过20秒未更新会提示延迟，约2分钟后实时查看到期。单独搜寻页面的橙线是已记录的观测点。请先读日期与GPS时间，不要认定为当前位置。点间直线并非实际山路或缺失时段的重建。",
    "fr": "La carte vise 5 s en mouvement et 15 s à l’arrêt, selon GPS, réseau et économie d’énergie. Le bleu montre jusqu’à 500 points récents ; le marqueur se déplace seulement entre positions reçues. Au-delà de 20 s, la position est signalée en retard ; l’accès direct expire après environ 2 min. L’orange du dossier séparé montre les relevés enregistrés. Lisez d’abord date et heure GPS. Les segments droits ne reconstituent ni sentier ni intervalle manquant.",
    "pt": "O mapa visa atualizações a cada 5 segundos em movimento e 15 parado, conforme GPS, rede e energia. Azul mostra até 500 pontos recentes; o marcador só se move entre coordenadas recebidas. Após mais de 20 segundos, indica atraso; o acesso ao vivo expira em cerca de 2 minutos. Laranja na tela de busca mostra observações registradas. Confira primeiro data e horário GPS. Linhas retas não reconstroem trilhas nem intervalos sem registro."
  },
  "07 · 보호자의 마지막 기록 조회와 동의": {
    "en": "07 · Consent and last-record access",
    "ja": "07・同意と保護者の最終記録閲覧",
    "zh": "07 · 同意与联系人查看最后记录",
    "fr": "07 · Consentement et accès au dernier relevé",
    "pt": "07 · Consentimento e acesso ao último registro"
  },
  "이동 화면에서 위치 공유를 켠 뒤 통신두절 대비 자료 공유에 별도로 동의해야 합니다. 실시간 위치만 공유를 선택하면 수색자료 보관 공유는 켜지지 않습니다. 동의한 경우 승인된 보호자는 가족·친구 위치 확인에서 상대 ID를 지정한 뒤 마지막 산행 기록 · 수색 참고자료를 엽니다. 서버 수신 후 최대 24시간 동안 마지막 GPS 위치·시각·경로·산행 시작·귀환 예정시간을 봅니다. 새 자료가 서버에 반영되면 조회 기한도 그 수신 기준으로 갱신됩니다. 24시간은 조회 기한이며 서버의 물리적 자동 삭제는 운영자의 별도 설정이 필요합니다.": {
    "en": "Enable location sharing, then separately consent to search-record sharing for connection loss. Choosing live location only does not enable it. Approved contacts select the hiker’s ID in Family & Friends and open Last hiking record · Search reference. For up to 24 hours after server receipt, they can view the last GPS fix, time, route, start and planned return. A new server update renews this access period. This is an access expiry; physical automatic deletion requires a separate operator setting.",
    "ja": "位置共有を有効にした後、通信途絶に備えた資料共有に別途同意してください。現在地のみ共有では捜索資料共有は有効になりません。承認済み保護者は家族・友人の位置確認でIDを指定し、最終登山記録・捜索参考資料を開きます。サーバー受信後最大24時間、最終GPS・時刻・経路・開始・帰還予定を閲覧できます。新しいサーバー更新で期限も更新します。24時間は閲覧期限であり、自動的な物理削除には運営側の別設定が必要です。",
    "zh": "开启位置共享后，须另外同意断网备用搜寻资料共享。选择仅实时位置不会启用搜寻资料共享。已批准联系人在家人朋友位置页指定徒步者ID，打开最后徒步记录与搜寻参考资料。服务器接收后最多24小时内可查看最后GPS、时间、路线、开始及预计返回。新的服务器更新会续期。24小时是访问期限，服务器物理自动删除需运营者另行设置。",
    "fr": "Activez le partage de position puis acceptez séparément le dossier en cas de coupure. « Position en direct seulement » ne l’active pas. Le proche autorisé choisit l’ID du randonneur dans les contacts puis ouvre le dernier relevé. Position GPS, heure, parcours, départ et retour prévu restent consultables jusqu’à 24 h après réception serveur. Une nouvelle mise à jour renouvelle ce délai. Il s’agit d’un délai d’accès ; l’effacement automatique physique nécessite un réglage de l’opérateur.",
    "pt": "Ative a localização e aceite separadamente o compartilhamento de registros para perda de conexão. Escolher apenas localização ao vivo não o ativa. Contatos aprovados selecionam o ID do caminhante e abrem o último registro e referência para busca. Por até 24 horas após recebimento, podem ver GPS, horário, rota, início e retorno previsto. Uma nova atualização renova o prazo. Trata-se de expiração do acesso; exclusão física automática exige configuração do operador."
  },
  "08 · 앱 재실행과 기록 이어가기": {
    "en": "08 · Reopening and resuming",
    "ja": "08・再起動と記録の再開",
    "zh": "08 · 重开应用与继续记录",
    "fr": "08 · Réouverture et reprise",
    "pt": "08 · Reabrir e retomar o registro"
  },
  "앱을 다시 열고 같은 계정으로 로그인한 뒤 안전산행 시작을 누르면 저장된 기록 이어가기 또는 새 산행을 선택할 수 있습니다. 이어가기는 저장된 점을 불러오고 새 GPS 관측부터 추가합니다. 앱이 꺼져 있던 시간의 위치는 복원하지 않습니다. 위치 공유는 자동으로 켜지지 않으므로 다시 동의해 시작하세요. 저장된 기록과 내보내기에서 이전 자료를 확인할 수 있습니다. 앱 삭제·저장소 초기화·브라우저 데이터 삭제는 기기 기록을 지울 수 있고, 다른 휴대폰으로 기기 기록이 자동 이전되지는 않습니다.": {
    "en": "Reopen the app, sign in to the same account and tap Start Hiking to choose Resume or New Hike. Resume loads saved points and adds new GPS observations; positions while the app was off are not recovered. Sharing does not start automatically: consent again. Saved records and export lets you inspect the old data. Uninstalling, resetting storage or clearing browser data can remove local records; device records do not automatically transfer to another phone.",
    "ja": "再起動後、同じアカウントでログインして登山開始を押すと、保存記録の再開か新しい登山を選べます。再開は保存点を読み、新しいGPS観測から追加します。停止中の位置は復元しません。共有は自動開始しないため再同意してください。保存記録と書き出しで以前の資料を確認できます。アプリ削除・保存領域初期化・ブラウザデータ削除で端末記録が消える場合があり、別端末へ自動移行もしません。",
    "zh": "重新打开应用并登录同一账户，点击开始徒步可选择继续记录或新徒步。继续记录会载入已存点并追加新GPS观测，无法恢复应用关闭期间的位置。共享不会自动开启，请重新同意。可从保存记录与导出查看旧资料。卸载、重置存储或清除浏览器数据可能删除设备记录；记录不会自动转移到另一手机。",
    "fr": "Rouvrez l’application avec le même compte puis démarrez la randonnée pour choisir reprise ou nouveau trajet. La reprise charge les points enregistrés et ajoute les nouvelles observations ; la période d’arrêt n’est pas reconstruite. Le partage ne redémarre pas automatiquement : consentez à nouveau. Consultez les anciens relevés dans l’export. Désinstallation, réinitialisation ou effacement du navigateur peuvent supprimer ces données, qui ne sont pas transférées automatiquement à un autre téléphone.",
    "pt": "Reabra com a mesma conta e toque em iniciar trilha para retomar ou começar outra. Retomar carrega os pontos salvos e acrescenta novas observações; não recupera posições enquanto o app estava desligado. Compartilhar não reinicia automaticamente: aceite novamente. Consulte os dados em registros salvos e exportação. Desinstalar, limpar armazenamento ou dados do navegador pode apagar registros locais; eles não passam automaticamente para outro celular."
  },
  "09 · 수색자료 내보내기와 전달": {
    "en": "09 · Exporting and passing on records",
    "ja": "09・捜索資料の書き出しと伝達",
    "zh": "09 · 导出与传递搜寻资料",
    "fr": "09 · Exporter et transmettre les relevés",
    "pt": "09 · Exportar e transmitir registros"
  },
  "산행자는 저장된 기록과 내보내기, 보호자는 수색 참고자료 화면에서 경로 파일 내보내기 또는 수색 요약 복사를 선택합니다. GeoJSON 파일에는 관측점·관측시각과 경로, 산행 시작 및 귀환 계획이 포함됩니다. 요약에는 마지막 좌표·시각과 지도 링크가 들어가며 필요한 수색 담당자에게 사용자가 직접 전달합니다. 파일을 지원하는 지도·GIS 프로그램에서 열어 날짜와 위치를 확인하세요. 기기 자료와 보호자 서버 자료는 점 개수나 최신 상태가 다를 수 있습니다. 파일은 앱에서 회수할 수 없으므로 공개 게시하지 말고 필요한 사람에게만 전달하세요.": {
    "en": "Hikers use Saved records and export; contacts use Search reference. Choose Export route file or Copy search summary. GeoJSON includes observed points, observation times, route, start and return plan. The summary includes last coordinates, time and a map link; you pass it directly to relevant search personnel. Open the file in a compatible map or GIS program and check dates and locations. Device and server copies can differ in point count and freshness. Exported files cannot be recalled; avoid public posting and share only as needed.",
    "ja": "登山者は保存記録と書き出し、保護者は捜索参考資料から経路ファイル書き出しまたは要約コピーを選びます。GeoJSONには観測点・時刻・経路・開始・帰還予定が入ります。要約には最終座標・時刻・地図リンクが入り、必要な捜索担当者へ自分で渡します。対応する地図・GISで日時と位置を確認してください。端末とサーバーでは点数や新しさが異なる場合があります。書き出したファイルは回収できないので公開せず、必要な人に限定してください。",
    "zh": "徒步者从保存记录与导出、联系人从搜寻参考资料页选择导出路线或复制摘要。GeoJSON含观测点、时间、路线、开始及返回计划。摘要含最后坐标、时间和地图链接，由用户直接交给所需搜寻人员。请用兼容的地图或GIS程序核对日期和位置。设备与服务器副本的点数、时效可能不同。导出文件无法收回，请勿公开发布，仅传给必要人员。",
    "fr": "Le randonneur ouvre les relevés enregistrés, le proche le dossier de recherche. Exportez le parcours ou copiez le résumé. GeoJSON contient points, heures, parcours, départ et retour prévu. Le résumé inclut dernières coordonnées, heure et lien cartographique : transmettez-le vous-même aux intervenants utiles. Vérifiez dates et positions dans un logiciel cartographique ou SIG compatible. Les copies locale et serveur peuvent différer. Un fichier exporté ne peut pas être récupéré ; évitez la publication publique.",
    "pt": "O caminhante abre registros salvos; o contato abre a referência para busca. Exporte a rota ou copie o resumo. GeoJSON inclui pontos, horários, rota, início e retorno previsto. O resumo traz últimas coordenadas, horário e link de mapa; você o entrega diretamente aos responsáveis necessários. Confira datas e posições em mapa ou GIS compatível. Cópias local e servidor podem ter pontos e atualização diferentes. Arquivos exportados não podem ser recuperados; evite publicação pública."
  },
  "10 · 공유 종료·접근 해제·삭제": {
    "en": "10 · Stop, revoke and delete",
    "ja": "10・共有停止・アクセス解除・削除",
    "zh": "10 · 停止、撤销与删除",
    "fr": "10 · Arrêter, révoquer et supprimer",
    "pt": "10 · Parar, revogar e excluir"
  },
  "공유 중지 또는 산행 종료 시 수색 서버 자료 삭제를 요청하며 기기에 삭제 대기를 남겨 재시도합니다. 오프라인에서는 삭제와 접근 해제의 서버 반영이 늦을 수 있어 기존 자료가 조회 기한까지 보일 수 있습니다. 특정 보호자를 해제하려면 승인된 보호자 목록에서 접근을 해제하세요. 종료 뒤 기기 기록은 내보내기를 위해 남으며 기기 기록과 서버 자료 삭제로 정리합니다. 서버 삭제 성공 뒤 기기 자료를 지우는 방식입니다. 이미 문자나 파일로 전달한 자료는 삭제되지 않습니다.": {
    "en": "Stopping sharing or ending the hike requests server-record deletion and keeps a local pending deletion for retries. Offline, deletion and revocation can be delayed, so existing records may remain accessible until expiry. Remove a particular contact in the approved contacts list. Device records remain after the hike for export; use Delete device and server records to remove them. Local deletion follows successful server deletion. Copies already sent by message or file are unaffected.",
    "ja": "共有停止・登山終了でサーバー資料の削除を要求し、端末に削除待ちを残して再試行します。オフラインでは削除・解除の反映が遅れ、期限まで以前の資料が見える場合があります。特定の保護者は承認済み一覧で解除してください。終了後も書き出し用に端末記録を保持し、端末とサーバーの記録削除で整理します。サーバー削除成功後に端末を消去します。送信済みメッセージやファイルは消えません。",
    "zh": "停止共享或结束徒步会请求删除服务器资料，并保留设备删除待办以重试。离线时删除和撤销可能延迟，旧资料可能在到期前仍可查看。撤销某联系人请使用已批准联系人列表。结束后设备记录保留用于导出，可用设备与服务器资料删除清理，服务器删除成功后才清除设备记录。已通过短信或文件发送的副本不受影响。",
    "fr": "L’arrêt du partage ou de la randonnée demande la suppression serveur et conserve une tâche locale à réessayer. Hors ligne, suppression et révocation peuvent être retardées : l’accès peut durer jusqu’à l’expiration. Retirez un proche dans la liste autorisée. Les relevés locaux restent disponibles pour l’export ; utilisez la suppression locale et serveur pour les effacer après confirmation serveur. Les copies déjà envoyées par message ou fichier restent inchangées.",
    "pt": "Parar o compartilhamento ou encerrar a trilha solicita exclusão no servidor e guarda uma pendência local para tentar novamente. Offline, exclusão e revogação podem atrasar e os dados permanecer acessíveis até expirar. Remova um contato na lista de aprovados. Registros locais ficam para exportar; use excluir registros locais e servidor para limpá-los após confirmação do servidor. Cópias enviadas por mensagem ou arquivo não são afetadas."
  },
  "11 · 보호자가 확인할 순서와 한계": {
    "en": "11 · Contact checklist and limits",
    "ja": "11・保護者の確認順序と限界",
    "zh": "11 · 联系人的核对顺序与限制",
    "fr": "11 · Vérifications du proche et limites",
    "pt": "11 · Verificações do contato e limites"
  },
  "위치가 멈췄다면 먼저 마지막 GPS 관측 날짜·시각, 서버 수신시각, 귀환 예정시간, 경로 끝점 순으로 확인하고 본인에게 연락을 시도하세요. 정지 표시만으로 조난이나 사고라고 판단할 수는 없습니다. 통신두절 후 새 위치를 원격으로 알아내는 기능은 없고, 자동 귀환 지연 알림·장시간 정지 신고·구조기관 자동 출동도 제공하지 않습니다. 실제 위험 상황에서는 확보한 기록과 시각을 필요한 현지 긴급기관에 직접 전달하세요. 위치 권한·통신·절전 상태에 따른 실제 휴대폰 동작 검증이 필요하며 이 앱만을 유일한 산행 안전수단으로 사용하지 마세요.": {
    "en": "If the position stops, check GPS date and time, server receipt, planned return, then route endpoint, and try contacting the hiker. A stationary display alone does not establish an accident. There is no remote discovery of new positions after connection loss, automatic overdue or prolonged-stop reporting, or automatic rescue dispatch. In an actual emergency, directly give available records and times to relevant local emergency services. Real-device behavior depends on permissions, connectivity and power settings; do not rely on this app as the sole hiking safety measure.",
    "ja": "位置が止まったらGPSの日付・時刻、サーバー受信、帰還予定、経路終点の順に確認し、本人への連絡を試みてください。停止表示だけで遭難や事故とは判断できません。通信途絶後の新しい位置取得、帰還遅延・長時間停止の自動通報、救助の自動出動はありません。実際の緊急時は記録と時刻を現地の適切な緊急機関に直接伝えてください。権限・通信・省電力による実機検証が必要で、このアプリだけに登山の安全を依存しないでください。",
    "zh": "位置停止时，先核对GPS日期时间、服务器接收时间、预计返回和路线末点，并尝试联系徒步者。仅静止显示不能判断遇险或事故。没有断网后远程获取新位置、超时返回或长时静止自动报告、自动救援出动功能。实际紧急时请将已获记录和时间直接交给当地相关紧急机构。设备表现取决于权限、网络与省电设置，需要实机验证，切勿仅依赖此应用保障徒步安全。",
    "fr": "Si la position s’arrête, vérifiez date et heure GPS, réception serveur, retour prévu puis dernier point, et tentez de joindre le randonneur. Un affichage immobile ne prouve pas un accident. Il n’existe ni nouvelle localisation à distance après coupure, ni signalement automatique de retard ou d’immobilité, ni déclenchement des secours. En urgence réelle, transmettez directement relevés et heures aux services locaux appropriés. Le fonctionnement dépend des permissions, du réseau et de l’énergie ; cette application ne doit pas être votre seule mesure de sécurité.",
    "pt": "Se a posição parar, confira data e horário GPS, recebimento no servidor, retorno previsto e último ponto, e tente falar com o caminhante. Uma tela parada não confirma acidente. Não há descoberta remota de novas posições após perda de conexão, alerta automático de atraso ou parada prolongada, nem despacho automático de resgate. Em emergência real, entregue registros e horários diretamente aos serviços locais adequados. Permissões, rede e energia exigem teste no aparelho; não use este app como única medida de segurança."
  },
  "안전산행 상세 안내": {
    "en": "Detailed hiking guide",
    "ja": "安全登山の詳細ガイド",
    "zh": "安全徒步详细指南",
    "fr": "Guide détaillé de randonnée",
    "pt": "Guia detalhado de trilha"
  },
  "통신두절에 대비해 기록하고, 마지막 관측을 수색의 참고자료로 활용하세요.": {
    "en": "Record for connection loss and use the last observations as search reference.",
    "ja": "通信途絶に備えて記録し、最後の観測を捜索の参考にしてください。",
    "zh": "为断网保存记录，将最后观测用作搜寻参考。",
    "fr": "Enregistrez avant les coupures et utilisez les derniers relevés pour aider la recherche.",
    "pt": "Registre antes de perder a conexão e use as últimas observações como referência para busca."
  },
  "네 가지 수색 보완 기능과 사용 순서": {
    "en": "Four search tools and how to use them",
    "ja": "4つの捜索補助機能と使い方",
    "zh": "四项搜寻辅助功能与使用顺序",
    "fr": "Quatre outils de recherche et leur utilisation",
    "pt": "Quatro ferramentas de busca e como usar"
  },
  "{count}개 관측점 · 이전 {dropped}개 삭제": {
    "en": "{count} observations · {dropped} earlier points discarded",
    "ja": "観測点{count}件・以前の{dropped}件を削除",
    "zh": "{count}个观测点 · 已删除此前{dropped}点",
    "fr": "{count} relevés · {dropped} anciens points supprimés",
    "pt": "{count} observações · {dropped} pontos anteriores descartados"
  },
  "연결 요청 읽기 실패: {code}\n로그인·이메일 인증 및 보호자 규칙 배포를 확인하세요.": {
    "en": "Could not read requests: {code}\nCheck sign-in, email verification and contact rules.",
    "ja": "申請を読めません：{code}\nログイン・メール認証・保護者ルールを確認してください。",
    "zh": "无法读取请求：{code}\n请检查登录、邮箱验证及联系人规则。",
    "fr": "Lecture des demandes impossible : {code}\nVérifiez connexion, e-mail et règles des contacts.",
    "pt": "Falha ao ler solicitações: {code}\nConfira login, e-mail e regras dos contatos."
  },
  "직접 전달받은 ID와 일치하는지 확인하세요.\n{id}\n승인 후 내가 공유를 시작한 동안 위치와 최근 경로를 볼 수 있습니다.": {
    "en": "Check that this is the ID you received directly.\n{id}\nOnce approved, this account can see location and recent route while you share.",
    "ja": "直接受け取ったIDと照合してください。\n{id}\n承認後、共有中に位置と最近の経路を閲覧できます。",
    "zh": "请核对是否为直接收到的ID。\n{id}\n批准后，此账户可在您共享期间查看位置及最近路线。",
    "fr": "Comparez cet ID à celui reçu directement.\n{id}\nAprès autorisation, ce compte voit position et trajet récent pendant le partage.",
    "pt": "Confira se é o ID recebido diretamente.\n{id}\nApós aprovação, esta conta vê posição e rota recente enquanto você compartilha."
  },
  "처리하지 못했습니다. 이메일·비밀번호와 인증 상태를 확인하세요. ({code})": {
    "en": "Action failed. Check email, password and verification. ({code})",
    "ja": "処理失敗。メール・パスワード・認証状態を確認してください。（{code}）",
    "zh": "操作失败。请检查邮箱、密码及验证状态。({code})",
    "fr": "Échec. Vérifiez e-mail, mot de passe et vérification. ({code})",
    "pt": "Falha. Confira e-mail, senha e verificação. ({code})"
  },
  "이동 종료 또는 위치 공유 중지로 공유를 종료합니다. 특정 계정의 접근은 승인된 보호자 목록에서 해제합니다. 실시간 지도는 이동 중 약 5초·정지 시 약 15초를 목표로 갱신하고 최근 최대 500점을 표시하며 약 2분 뒤 조회가 만료됩니다. 별도 동의한 산행 수색자료는 서버 수신 후 최대 24시간 조회됩니다. 오프라인에서는 종료·삭제 반영이 지연될 수 있습니다. 자세한 차이는 안전산행 상세 안내를 확인하세요.": {
    "en": "End the trip or stop sharing; revoke an individual in approved contacts. Live updates target 5 seconds moving and 15 stationary, show up to 500 points, and expire after about 2 minutes. Separately consented hiking search records remain accessible up to 24 hours after server receipt. Offline, stop and deletion may be delayed. See the detailed hiking guide.",
    "ja": "移動終了または共有停止で終了し、個別の相手は承認済み一覧で解除します。現在地更新は移動中約5秒・停止中約15秒を目標とし、最大500点を表示、約2分で閲覧期限が切れます。別途同意した登山捜索資料は受信後最大24時間閲覧できます。オフラインでは終了・削除の反映が遅れる場合があります。詳細ガイドをご確認ください。",
    "zh": "结束行程或停止共享，个别联系人可在批准列表中撤销。实时目标为移动时5秒、静止时15秒更新，显示最多500点，约2分钟后到期。单独同意的徒步搜寻资料可在服务器接收后最多查看24小时。离线时停止和删除可能延迟。请参阅详细徒步指南。",
    "fr": "Terminez le trajet ou arrêtez le partage ; révoquez un proche dans la liste autorisée. Le direct vise 5 s en mouvement et 15 s à l’arrêt, affiche 500 points au plus et expire après environ 2 min. Le dossier de randonnée accepté séparément reste accessible jusqu’à 24 h après réception. Hors ligne, arrêt et suppression peuvent être retardés. Voir le guide détaillé.",
    "pt": "Encerre o trajeto ou pare de compartilhar; revogue contatos na lista aprovada. O mapa visa 5 segundos em movimento e 15 parado, mostra até 500 pontos e expira em cerca de 2 minutos. Dados de busca consentidos separadamente ficam acessíveis por até 24 horas após recebimento. Offline, parada e exclusão podem atrasar. Veja o guia detalhado."
  },
  "계정은 생성되었습니다. 인증 메일 다시 보내기를 눌러주세요.": {
    "en": "Account created. Tap Resend verification email.",
    "ja": "アカウントを作成しました。認証メールの再送を押してください。",
    "zh": "账户已创建，请点击重新发送验证邮件。",
    "fr": "Compte créé. Renvoyez l’e-mail de vérification.",
    "pt": "Conta criada. Toque em reenviar e-mail de verificação."
  },
  "가입했습니다. 이메일의 인증 링크를 누른 뒤 인증 상태를 새로고침해주세요.": {
    "en": "Account created. Open the email verification link, then refresh verification status.",
    "ja": "登録しました。メールの認証リンクを開き、認証状態を更新してください。",
    "zh": "注册成功。请打开邮件中的验证链接，再刷新验证状态。",
    "fr": "Inscription réussie. Ouvrez le lien reçu, puis actualisez la vérification.",
    "pt": "Cadastro concluído. Abra o link do e-mail e atualize a verificação."
  },
  "ORQUBE {mode} 이동을 종료했습니다. 현재 좌표: {url}": {
    "en": "ORQUBE {mode} trip ended. Coordinates: {url}",
    "ja": "ORQUBE {mode}を終了しました。現在の座標：{url}",
    "zh": "ORQUBE {mode}行程已结束。坐标：{url}",
    "fr": "Trajet ORQUBE {mode} terminé. Coordonnées : {url}",
    "pt": "Trajeto ORQUBE {mode} encerrado. Coordenadas: {url}"
  },
  "ORQUBE {mode} 현재 좌표입니다. 귀환 예정: {time} · 지도: {url}": {
    "en": "ORQUBE {mode} coordinates. Planned return: {time} · Map: {url}",
    "ja": "ORQUBE {mode}の座標です。帰還予定：{time}・地図：{url}",
    "zh": "ORQUBE {mode}坐标。预计返回：{time} · 地图：{url}",
    "fr": "Coordonnées ORQUBE {mode}. Retour prévu : {time} · Carte : {url}",
    "pt": "Coordenadas ORQUBE {mode}. Retorno previsto: {time} · Mapa: {url}"
  },
  "기기 기록을 읽지 못했습니다.": {
    "en": "Could not read device records.",
    "ja": "端末の記録を読めませんでした。",
    "zh": "无法读取设备记录。",
    "fr": "Impossible de lire les données locales.",
    "pt": "Não foi possível ler os registros locais."
  },
  "안전산행은 산행 경로·귀환 계획을 기록합니다. 기기 우선 저장, 통신 복구 후 재전송, 동의한 보호자의 마지막 기록 조회, 경로 파일 내보내기를 제공합니다. 사용 순서와 통신두절 시 한계는 상세 안내에서 확인하세요.": {
    "en": "Safe Hiking records your route and return plan. It offers device-first saving, retry after reconnection, consented last-record access for approved contacts, and route file export. See the detailed guide for steps and connection-loss limits.",
    "ja": "安全登山は経路と帰還計画を記録します。端末優先保存、接続回復後の再送、同意に基づく保護者の最終記録閲覧、経路ファイル書き出しを提供します。使い方と通信途絶時の限界は詳細ガイドをご確認ください。",
    "zh": "安全徒步记录路线和返回计划，提供设备优先保存、网络恢复后重传、经同意的联系人查看最后记录及路线文件导出。使用步骤和断网限制请查看详细指南。",
    "fr": "La randonnée sûre enregistre parcours et retour prévu : sauvegarde locale prioritaire, nouvel envoi après reconnexion, dernier relevé accessible avec consentement et export du parcours. Consultez le guide pour les étapes et les limites en cas de coupure.",
    "pt": "A trilha segura registra rota e retorno previsto: gravação local, reenvio após reconexão, acesso consentido ao último registro e exportação da rota. Veja o guia para etapas e limites na perda de conexão."
  },
  "가족": {
    "en": "Family",
    "ja": "家族",
    "zh": "家人",
    "fr": "Famille",
    "pt": "Família"
  },
  "친구": {
    "en": "Friend",
    "ja": "友人",
    "zh": "朋友",
    "fr": "Ami",
    "pt": "Amigo"
  },
  "산행 동료": {
    "en": "Hiking companion",
    "ja": "登山仲間",
    "zh": "徒步同伴",
    "fr": "Compagnon de randonnée",
    "pt": "Companheiro de trilha"
  },
  "내 사람·모임": {
    "en": "People & groups",
    "ja": "連絡先・グループ",
    "zh": "联系人与分组",
    "fr": "Proches et groupes",
    "pt": "Pessoas e grupos"
  },
  "가족·친구 연결 · 변경 · 공유 중지 · 해제": {
    "en": "Connect · Edit · Stop sharing · Disconnect",
    "ja": "連携・変更・共有停止・解除",
    "zh": "连接 · 修改 · 停止共享 · 解除",
    "fr": "Connecter · Modifier · Arrêter · Déconnecter",
    "pt": "Conectar · Editar · Parar · Desconectar"
  },
  "사람 추가": {
    "en": "Add person",
    "ja": "連絡先を追加",
    "zh": "添加联系人",
    "fr": "Ajouter un proche",
    "pt": "Adicionar pessoa"
  },
  "연결된 사람이 없습니다.": {
    "en": "No connected people.",
    "ja": "連携済みの相手はいません。",
    "zh": "暂无已连接的联系人。",
    "fr": "Aucun proche connecté.",
    "pt": "Nenhuma pessoa conectada."
  },
  "내 사람·모임에서 가족·친구를 추가하고 상대가 초대를 수락한 뒤 공유할 수 있습니다.": {
    "en": "Add family or friends in People & groups. Sharing is available after they accept your invitation.",
    "ja": "連絡先・グループで家族や友人を追加し、相手の招待承認後に共有できます。",
    "zh": "在联系人与分组中添加家人朋友，对方接受邀请后即可共享。",
    "fr": "Ajoutez des proches. Le partage est disponible après acceptation de l’invitation.",
    "pt": "Adicione familiares ou amigos. Compartilhe após aceitarem o convite."
  },
  "공유 대상 선택": {
    "en": "Choose recipients",
    "ja": "共有相手を選択",
    "zh": "选择共享对象",
    "fr": "Choisir les destinataires",
    "pt": "Escolher destinatários"
  },
  "연결만으로 위치가 공개되지 않습니다. 이번 이동에 공유할 사람을 선택하세요.": {
    "en": "Connecting does not expose your location. Choose people for this trip.",
    "ja": "連携だけで位置は公開されません。今回共有する相手を選んでください。",
    "zh": "连接不会自动公开位置，请选择本次行程的共享对象。",
    "fr": "La connexion ne dévoile pas la position. Choisissez les proches pour ce trajet.",
    "pt": "Conectar não revela a posição. Escolha as pessoas para este percurso."
  },
  "수색자료 조회는 사람마다 별도로 선택합니다. 서버 수신 후 최대 24시간 마지막 기록을 볼 수 있습니다.": {
    "en": "Allow search-record access separately for each person. They can view the last record for up to 24 hours after server receipt.",
    "ja": "捜索記録の閲覧は相手ごとに選びます。サーバー受信後最大24時間、最終記録を閲覧できます。",
    "zh": "搜寻记录访问须逐人选择，可在服务器接收后最多24小时查看最后记录。",
    "fr": "Autorisez le dossier de recherche par personne, jusqu’à 24 h après réception serveur.",
    "pt": "Autorize os registros de busca por pessoa, por até 24 horas após recebimento."
  },
  "마지막 산행 기록 조회 허용": {
    "en": "Allow last hiking record access",
    "ja": "最終登山記録の閲覧を許可",
    "zh": "允许查看最后徒步记录",
    "fr": "Autoriser le dernier relevé de randonnée",
    "pt": "Permitir acesso ao último registro de trilha"
  },
  "선택 적용": {
    "en": "Apply selection",
    "ja": "選択を適用",
    "zh": "应用选择",
    "fr": "Appliquer la sélection",
    "pt": "Aplicar seleção"
  },
  "공유 대상 변경": {
    "en": "Change recipients",
    "ja": "共有相手を変更",
    "zh": "更改共享对象",
    "fr": "Modifier les destinataires",
    "pt": "Alterar destinatários"
  },
  "목록을 읽지 못했습니다. 인터넷·로그인·새 보안 규칙을 확인하고 다시 시도하세요.": {
    "en": "Could not load the list. Check internet, sign-in and new security rules, then retry.",
    "ja": "一覧を読めません。通信・ログイン・新しいセキュリティルールを確認して再試行してください。",
    "zh": "无法加载列表。请检查网络、登录和新安全规则后重试。",
    "fr": "Liste indisponible. Vérifiez réseau, connexion et nouvelles règles, puis réessayez.",
    "pt": "Não foi possível carregar a lista. Confira rede, login e novas regras e tente novamente."
  },
  "변경하지 못했습니다. 연결 상태와 권한을 확인한 뒤 다시 시도하세요.": {
    "en": "Could not save the change. Check connection and permissions, then retry.",
    "ja": "変更できませんでした。通信と権限を確認して再試行してください。",
    "zh": "无法保存更改，请检查连接和权限后重试。",
    "fr": "Modification impossible. Vérifiez connexion et permissions, puis réessayez.",
    "pt": "Não foi possível salvar. Confira conexão e permissões e tente novamente."
  },
  "초대 수락": {
    "en": "Accept invitation",
    "ja": "招待を承認",
    "zh": "接受邀请",
    "fr": "Accepter l’invitation",
    "pt": "Aceitar convite"
  },
  "이름·관계 변경": {
    "en": "Edit name & relationship",
    "ja": "名前・関係を変更",
    "zh": "修改姓名与关系",
    "fr": "Modifier nom et relation",
    "pt": "Editar nome e relação"
  },
  "이름과 관계는 내 목록에만 표시됩니다. 연결 ID를 본인에게 확인하세요.": {
    "en": "Names and relationships are private to your list. Verify the connection ID with the person.",
    "ja": "名前と関係は自分の一覧だけに表示されます。接続IDを本人に確認してください。",
    "zh": "姓名和关系仅在本人列表显示。请向对方核实连接ID。",
    "fr": "Noms et relations restent privés dans votre liste. Vérifiez l’ID avec la personne.",
    "pt": "Nomes e relações ficam só na sua lista. Confirme o ID com a pessoa."
  },
  "표시 이름": {
    "en": "Display name",
    "ja": "表示名",
    "zh": "显示名称",
    "fr": "Nom affiché",
    "pt": "Nome exibido"
  },
  "상대방 연결 ID": {
    "en": "Other person’s connection ID",
    "ja": "相手の接続ID",
    "zh": "对方连接ID",
    "fr": "ID du proche",
    "pt": "ID da outra pessoa"
  },
  "수락": {
    "en": "Accept",
    "ja": "承認",
    "zh": "接受",
    "fr": "Accepter",
    "pt": "Aceitar"
  },
  "초대 보내기": {
    "en": "Send invitation",
    "ja": "招待を送る",
    "zh": "发送邀请",
    "fr": "Envoyer l’invitation",
    "pt": "Enviar convite"
  },
  "내 산행 모임": {
    "en": "My hiking groups",
    "ja": "自分の登山グループ",
    "zh": "我的徒步分组",
    "fr": "Mes groupes de randonnée",
    "pt": "Meus grupos de trilha"
  },
  "내가 공유 대상을 고르기 위한 묶음입니다. 모임에 넣어도 위치가 자동 공개되지 않습니다.": {
    "en": "A private group for selecting recipients. Adding someone does not share location automatically.",
    "ja": "共有相手を選ぶための自分用グループです。追加だけで位置は公開されません。",
    "zh": "这是便于选择共享对象的私有分组，加入分组不会自动共享位置。",
    "fr": "Un groupe privé pour sélectionner les destinataires. L’ajout ne partage pas la position.",
    "pt": "Grupo privado para escolher destinatários. Adicionar alguém não compartilha a posição."
  },
  "모임 이름": {
    "en": "Group name",
    "ja": "グループ名",
    "zh": "分组名称",
    "fr": "Nom du groupe",
    "pt": "Nome do grupo"
  },
  "가족·친구를 한 번 연결한 뒤 산행·귀가·위치 공유에서 대상을 선택하세요.": {
    "en": "Connect family and friends once, then select them for hiking, safe return or location sharing.",
    "ja": "家族・友人を連携したら、登山・帰宅・位置共有で相手を選びます。",
    "zh": "连接家人朋友后，可在徒步、回家或位置共享中选择他们。",
    "fr": "Connectez vos proches une fois, puis sélectionnez-les pour randonnée, retour ou partage.",
    "pt": "Conecte familiares e amigos uma vez e selecione-os para trilha, volta ou localização."
  },
  "모임 만들기": {
    "en": "Create group",
    "ja": "グループを作成",
    "zh": "创建分组",
    "fr": "Créer un groupe",
    "pt": "Criar grupo"
  },
  "새로고침": {
    "en": "Refresh",
    "ja": "更新",
    "zh": "刷新",
    "fr": "Actualiser",
    "pt": "Atualizar"
  },
  "내 연결 ID 복사": {
    "en": "Copy my connection ID",
    "ja": "自分の接続IDをコピー",
    "zh": "复制我的连接ID",
    "fr": "Copier mon ID",
    "pt": "Copiar meu ID"
  },
  "받은 초대": {
    "en": "Received invitations",
    "ja": "受け取った招待",
    "zh": "收到的邀请",
    "fr": "Invitations reçues",
    "pt": "Convites recebidos"
  },
  "받은 초대가 없습니다.": {
    "en": "No received invitations.",
    "ja": "受け取った招待はありません。",
    "zh": "没有收到邀请。",
    "fr": "Aucune invitation reçue.",
    "pt": "Nenhum convite recebido."
  },
  "거절": {
    "en": "Decline",
    "ja": "辞退",
    "zh": "拒绝",
    "fr": "Refuser",
    "pt": "Recusar"
  },
  "연결된 사람": {
    "en": "Connected people",
    "ja": "連携した相手",
    "zh": "已连接的人",
    "fr": "Proches connectés",
    "pt": "Pessoas conectadas"
  },
  "연결된 사람이 없습니다. 사람 추가를 눌러 초대를 보내세요.": {
    "en": "No connected people. Tap Add person to invite someone.",
    "ja": "連携した相手はいません。連絡先を追加から招待してください。",
    "zh": "暂无已连接的人，请点击添加联系人发送邀请。",
    "fr": "Aucun proche connecté. Ajoutez une personne pour l’inviter.",
    "pt": "Ninguém conectado. Toque em Adicionar pessoa para convidar."
  },
  "이번 위치 공유에 선택됨": {
    "en": "Selected for this location share",
    "ja": "今回の位置共有に選択済み",
    "zh": "已选为本次位置共享对象",
    "fr": "Sélectionné pour ce partage",
    "pt": "Selecionado para este compartilhamento"
  },
  "현재 내 위치 공유 대상 아님": {
    "en": "Not selected for my current location share",
    "ja": "現在の自分の位置共有対象ではありません",
    "zh": "未选为当前的位置共享对象",
    "fr": "Non sélectionné pour ce partage",
    "pt": "Não selecionado para compartilhar minha posição"
  },
  "상대 위치 보기": {
    "en": "View their location",
    "ja": "相手の位置を見る",
    "zh": "查看对方位置",
    "fr": "Voir sa position",
    "pt": "Ver localização da pessoa"
  },
  "이 사람에게 공유 중지": {
    "en": "Stop sharing with this person",
    "ja": "この相手への共有を停止",
    "zh": "停止向此人共享",
    "fr": "Arrêter le partage avec ce proche",
    "pt": "Parar de compartilhar com esta pessoa"
  },
  "연결은 유지하고 현재 위치와 수색자료 조회 대상에서만 제외합니다.": {
    "en": "Keep the connection but remove current location and search-record access.",
    "ja": "連携は残し、現在地と捜索記録の閲覧対象から外します。",
    "zh": "保留连接，仅移除当前位置和搜寻资料访问权限。",
    "fr": "Conservez la connexion mais retirez l’accès à la position et au dossier de recherche.",
    "pt": "Mantenha a conexão, mas remova acesso à localização e aos registros de busca."
  },
  "연결 해제": {
    "en": "Disconnect",
    "ja": "連携解除",
    "zh": "解除连接",
    "fr": "Déconnecter",
    "pt": "Desconectar"
  },
  "양쪽 위치·수색자료 접근 연결을 해제합니다. 다시 연결하려면 새 초대와 수락이 필요합니다. 오프라인에서는 서버 반영이 지연될 수 있습니다.": {
    "en": "Revoke location and search access in both directions. Reconnecting requires a new invitation and acceptance. Offline server updates may be delayed.",
    "ja": "双方の位置・捜索資料への連携を解除します。再連携には新しい招待と承認が必要です。オフラインでは反映が遅れる場合があります。",
    "zh": "撤销双方的位置及搜寻资料连接。重新连接需要新邀请与接受。离线时服务器更新可能延迟。",
    "fr": "Révoquez l’accès dans les deux sens. Une nouvelle invitation acceptée sera nécessaire. Hors ligne, la mise à jour peut être retardée.",
    "pt": "Revogue o acesso nos dois sentidos. Para reconectar, é preciso novo convite aceito. Offline, a atualização pode atrasar."
  },
  "보낸 초대 · 수락 대기": {
    "en": "Sent invitations · Pending",
    "ja": "送った招待・承認待ち",
    "zh": "已发邀请 · 待接受",
    "fr": "Invitations envoyées · En attente",
    "pt": "Convites enviados · Pendentes"
  },
  "초대 취소": {
    "en": "Cancel invitation",
    "ja": "招待を取り消す",
    "zh": "取消邀请",
    "fr": "Annuler l’invitation",
    "pt": "Cancelar convite"
  },
  "모임이 없습니다. 연결된 사람을 묶어 공유 대상을 쉽게 고를 수 있습니다.": {
    "en": "No groups. Group connected people to select recipients easily.",
    "ja": "グループはありません。連携相手をまとめると共有先を選びやすくなります。",
    "zh": "暂无分组，可将已连接的人分组以便选择共享对象。",
    "fr": "Aucun groupe. Regroupez les proches pour faciliter la sélection.",
    "pt": "Sem grupos. Agrupe pessoas conectadas para escolher destinatários facilmente."
  },
  "모임 변경": {
    "en": "Edit group",
    "ja": "グループを変更",
    "zh": "修改分组",
    "fr": "Modifier le groupe",
    "pt": "Editar grupo"
  },
  "모임 삭제": {
    "en": "Delete group",
    "ja": "グループを削除",
    "zh": "删除分组",
    "fr": "Supprimer le groupe",
    "pt": "Excluir grupo"
  },
  "내 모임 묶음만 삭제합니다. 사람 연결과 진행 중 공유는 유지됩니다.": {
    "en": "Delete only this private group. Connections and current sharing remain.",
    "ja": "自分のグループだけを削除します。連携と共有中の状態は維持されます。",
    "zh": "仅删除此私有分组，联系人连接及正在进行的共享保持不变。",
    "fr": "Supprimez seulement ce groupe privé. Connexions et partage en cours sont conservés.",
    "pt": "Exclua só este grupo privado. Conexões e compartilhamento atual permanecem."
  },
  "상대가 나를 공유 대상으로 선택했는지 확인하세요. 종료·만료·연결 해제 또는 통신 문제일 수도 있습니다.": {
    "en": "Check that the person selected you as a recipient. Sharing may have ended, expired, been disconnected, or lost connectivity.",
    "ja": "相手が自分を共有先に選んだか確認してください。終了・期限切れ・連携解除・通信問題の場合もあります。",
    "zh": "请确认对方选择了您作为共享对象，也可能是共享结束、过期、解除连接或网络问题。",
    "fr": "Vérifiez que le proche vous a sélectionné. Le partage peut être terminé, expiré, révoqué ou hors ligne.",
    "pt": "Confira se a pessoa selecionou você. O compartilhamento pode ter terminado, expirado, sido revogado ou perdido conexão."
  },
  "공유 대상을 읽지 못했습니다. 새 보안 규칙과 연결 상태를 확인하세요.": {
    "en": "Could not load recipients. Check the new security rules and connection.",
    "ja": "共有先を読めません。新しいセキュリティルールと通信を確認してください。",
    "zh": "无法读取共享对象，请检查新安全规则与网络。",
    "fr": "Destinataires indisponibles. Vérifiez les nouvelles règles et la connexion.",
    "pt": "Não foi possível carregar destinatários. Confira novas regras e conexão."
  },
  "가족·친구와 30분 위치 공유": {
    "en": "Share location for 30 minutes with family & friends",
    "ja": "家族・友人と30分位置共有",
    "zh": "与家人朋友共享位置30分钟",
    "fr": "Partager 30 min avec les proches",
    "pt": "Compartilhar por 30 minutos com familiares e amigos"
  },
  "산행이나 귀가를 시작하지 않아도 선택한 사람에게 현재 위치와 최근 경로를 공유합니다. 이 화면을 떠나면 공유 종료를 시도합니다.": {
    "en": "Share current location and recent route without starting a hike or return. Leaving this screen attempts to stop sharing.",
    "ja": "登山や帰宅を始めずに現在地と最近の経路を共有します。この画面を離れると共有停止を試みます。",
    "zh": "无需开始徒步或回家即可共享当前位置和最近路线，离开此页会尝试停止共享。",
    "fr": "Partagez position et trajet récent sans démarrer randonnée ou retour. Quitter cet écran tente d’arrêter le partage.",
    "pt": "Compartilhe posição e rota recente sem iniciar trilha ou volta. Sair desta tela tenta parar o compartilhamento."
  },
  "위치 수신이 지연되고 있습니다. GPS와 권한을 확인하세요.": {
    "en": "Location updates are delayed. Check GPS and permissions.",
    "ja": "位置受信が遅れています。GPSと権限を確認してください。",
    "zh": "位置更新延迟，请检查GPS与权限。",
    "fr": "Position en retard. Vérifiez GPS et permissions.",
    "pt": "Atualizações atrasadas. Confira GPS e permissões."
  },
  "공유를 시작하지 못했습니다. 로그인·이메일 인증·위치 권한·인터넷을 확인하세요.": {
    "en": "Could not start sharing. Check sign-in, verified email, location permission and internet.",
    "ja": "共有を開始できません。ログイン・メール認証・位置権限・通信を確認してください。",
    "zh": "无法开始共享，请检查登录、邮箱验证、位置权限与网络。",
    "fr": "Partage impossible. Vérifiez connexion, e-mail, localisation et réseau.",
    "pt": "Não foi possível compartilhar. Confira login, e-mail, permissão de localização e rede."
  },
  "공유 대상": {
    "en": "Recipients",
    "ja": "共有相手",
    "zh": "共享对象",
    "fr": "Destinataires",
    "pt": "Destinatários"
  },
  "공유 대상 선택 · 시작": {
    "en": "Choose recipients · Start",
    "ja": "共有先を選択・開始",
    "zh": "选择共享对象 · 开始",
    "fr": "Choisir les destinataires · Démarrer",
    "pt": "Escolher destinatários · Iniciar"
  },
  "표시된 지도는 이 기기의 GPS 기록입니다. 상대방의 수신 완료를 뜻하지 않습니다. 통신·절전·앱 종료 시 갱신이 중단될 수 있습니다.": {
    "en": "This map shows device GPS observations, not confirmed receipt by others. Network, power saving or closing the app may interrupt updates.",
    "ja": "この地図は端末のGPS記録で、相手の受信完了を意味しません。通信・省電力・終了により更新が止まる場合があります。",
    "zh": "地图显示本设备GPS记录，不代表对方已接收。网络、省电或关闭应用可能中断更新。",
    "fr": "Cette carte montre le GPS local, pas une réception confirmée. Réseau, économie d’énergie ou fermeture peuvent interrompre les mises à jour.",
    "pt": "O mapa mostra GPS local, não confirma recebimento. Rede, economia de energia ou fechamento podem interromper atualizações."
  },
  "내 사람·모임에서 사람 추가를 누르고 표시 이름·가족 또는 친구 등 관계·상대방 연결 ID를 입력해 초대합니다. 상대방은 받은 초대에서 ID를 확인하고 수락합니다. 연결된 뒤에도 위치는 자동 공개되지 않습니다. 산행·귀가·위치 공유 화면에서 공유 대상을 선택하고 시작해야 합니다. 이름·관계는 각자의 목록에서 따로 관리하며 전화번호만으로 위치를 조회하지 않습니다.": {
    "en": "In People & groups, add a person with a display name, relationship and connection ID. The recipient verifies the ID and accepts the invitation. Connecting alone never shares location. Choose recipients and start sharing in Hiking, Safe Return or Location Sharing. Each person keeps private names and relationships. Phone numbers alone cannot locate anyone.",
    "ja": "連絡先・グループで名前・家族や友人などの関係・接続IDを入力して招待します。相手がIDを確認して承認します。連携だけで位置は公開されません。登山・帰宅・位置共有で相手を選んで開始してください。名前と関係はそれぞれの一覧で管理し、電話番号だけでは位置を調べません。",
    "zh": "在联系人与分组中输入显示名、家人朋友等关系及连接ID发送邀请，对方核对ID后接受。连接不会自动共享位置，须在徒步、回家或位置共享中选择对象并开始。双方各自管理显示名和关系，无法仅凭电话号码定位。",
    "fr": "Dans Proches et groupes, invitez avec nom, relation et ID. Le destinataire vérifie l’ID et accepte. La connexion seule ne partage jamais la position : choisissez les destinataires et démarrez depuis randonnée, retour ou localisation. Chacun gère ses noms et relations privés. Un numéro seul ne permet pas de localiser.",
    "pt": "Em Pessoas e grupos, convide com nome, relação e ID. O destinatário confere o ID e aceita. Conectar não compartilha posição automaticamente: escolha pessoas e inicie na trilha, volta ou localização. Cada um gerencia nomes e relações privados. Telefone sozinho não localiza ninguém."
  },
  "04 · 내 사람·모임": {
    "en": "04 · People & groups",
    "ja": "04・連絡先・グループ",
    "zh": "04 · 联系人与分组",
    "fr": "04 · Proches et groupes",
    "pt": "04 · Pessoas e grupos"
  },
  "이름·관계 변경은 내 목록의 표시만 바꿉니다. 공유 중지는 연결을 유지하면서 현재 위치와 수색자료 조회 대상에서 제외합니다. 연결 해제는 양쪽 접근 연결을 취소하며 다시 초대하고 수락해야 연결됩니다. 모임 삭제는 내 공유 대상 묶음만 지우며 연결과 진행 중 공유는 그대로입니다. 오프라인에서는 서버 반영이 지연될 수 있습니다.": {
    "en": "Editing names or relationships changes your private list only. Stop sharing removes current location and search-record access but keeps the connection. Disconnect revokes access in both directions; reconnecting requires a new accepted invitation. Deleting a group removes only the private recipient group. Offline changes may be delayed.",
    "ja": "名前・関係の変更は自分の表示だけを変えます。共有停止は連携を残して現在地と捜索記録の閲覧を外します。連携解除は双方のアクセスを取り消し、再招待と承認が必要です。グループ削除は自分の共有先のまとまりだけを消します。オフラインでは反映が遅れる場合があります。",
    "zh": "修改姓名关系仅影响个人列表。停止共享保留连接但移除当前位置与搜寻记录访问。解除连接撤销双方访问，重新连接需新邀请与接受。删除分组仅删除私有共享对象分组。离线更改可能延迟。",
    "fr": "Modifier nom ou relation ne change que votre liste. Arrêter le partage retire position et dossier mais garde la connexion. Déconnecter révoque les accès dans les deux sens ; une nouvelle invitation acceptée est nécessaire. Supprimer un groupe retire seulement votre regroupement privé. Hors ligne, les changements peuvent être retardés.",
    "pt": "Editar nome ou relação muda só sua lista. Parar remove acesso à posição e aos registros, mas mantém a conexão. Desconectar revoga nos dois sentidos e exige novo convite aceito. Excluir grupo remove só o agrupamento privado. Offline, mudanças podem atrasar."
  },
  "12 · 가족·친구 연결과 변경": {
    "en": "12 · Connecting and editing people",
    "ja": "12・家族・友人の連携と変更",
    "zh": "12 · 家人朋友连接与修改",
    "fr": "12 · Connecter et modifier les proches",
    "pt": "12 · Conectar e editar pessoas"
  },
  "13 · 공유 중지·연결 해제·모임 삭제": {
    "en": "13 · Stop, disconnect and delete groups",
    "ja": "13・共有停止・連携解除・グループ削除",
    "zh": "13 · 停止共享、解除连接与删除分组",
    "fr": "13 · Arrêter, déconnecter et supprimer un groupe",
    "pt": "13 · Parar, desconectar e excluir grupo"
  },
  "공유 대상: {name} • 자동 알림 미지원": {
    "en": "Recipients: {name} • No automatic alerts",
    "ja": "共有相手：{name}・自動通知なし",
    "zh": "共享对象：{name} · 无自动通知",
    "fr": "Destinataires : {name} · Pas d’alerte automatique",
    "pt": "Destinatários: {name} · Sem alerta automático"
  },
  "닫기": {
    "en": "Close",
    "ja": "閉じる",
    "zh": "关闭",
    "fr": "Fermer",
    "pt": "Fechar"
  },
  "공유 중지": {
    "en": "Stop sharing",
    "ja": "共有停止",
    "zh": "停止共享",
    "fr": "Arrêter le partage",
    "pt": "Parar compartilhamento"
  },
  "이용 안내": {
    "en": "Introduction",
    "ja": "利用案内",
    "zh": "使用说明",
    "fr": "Introduction",
    "pt": "Introdução"
  },
  "동의 확인": {
    "en": "Consent",
    "ja": "同意確認",
    "zh": "同意确认",
    "fr": "Consentement",
    "pt": "Consentimento"
  },
  "내 위치 확인": {
    "en": "Check my location",
    "ja": "現在地を確認",
    "zh": "确认我的位置",
    "fr": "Vérifier ma position",
    "pt": "Conferir minha posição"
  },
  "목적지·귀환 계획": {
    "en": "Destination & return plan",
    "ja": "目的地・帰還計画",
    "zh": "目的地与返回计划",
    "fr": "Destination et retour",
    "pt": "Destino e retorno"
  },
  "공유 대상 설정": {
    "en": "Sharing recipients",
    "ja": "共有先の設定",
    "zh": "设置共享对象",
    "fr": "Destinataires",
    "pt": "Destinatários"
  },
  "최종 확인": {
    "en": "Final review",
    "ja": "最終確認",
    "zh": "最终确认",
    "fr": "Vérification finale",
    "pt": "Revisão final"
  },
  "위치를 확인하지 못했습니다. 기기 위치 서비스와 앱 위치 권한을 확인하고 다시 눌러주세요.": {
    "en": "Could not get your position. Check device location services and app permissions, then retry.",
    "ja": "現在地を確認できません。端末の位置サービスとアプリの権限を確認して再試行してください。",
    "zh": "无法确认位置，请检查设备定位服务及应用权限后重试。",
    "fr": "Position indisponible. Vérifiez la localisation et les permissions, puis réessayez.",
    "pt": "Não foi possível obter a posição. Confira localização e permissões e tente novamente."
  },
  "목적지를 찾지 못했습니다. 주소를 바꾸거나 지도에서 직접 선택하세요.": {
    "en": "Destination not found. Change the address or select directly on the map.",
    "ja": "目的地が見つかりません。住所を変えるか地図で直接選んでください。",
    "zh": "找不到目的地，请更改地址或直接在地图选择。",
    "fr": "Destination introuvable. Modifiez l’adresse ou sélectionnez sur la carte.",
    "pt": "Destino não encontrado. Altere o endereço ou selecione no mapa."
  },
  "위치를 확인한 지 시간이 지났습니다. 내 위치를 다시 확인해주세요.": {
    "en": "Your location check is old. Please check your position again.",
    "ja": "位置確認から時間が経ちました。現在地を再確認してください。",
    "zh": "位置确认已过一段时间，请重新确认。",
    "fr": "La position vérifiée est ancienne. Vérifiez-la à nouveau.",
    "pt": "A verificação está antiga. Confira sua posição novamente."
  },
  "몇 단계만 따라 하면 산행 준비가 끝납니다. 설명을 읽고 동의·위치·목적지·공유 대상을 차례로 확인하세요.": {
    "en": "Prepare your hike in a few steps. Read the introduction, then review consent, location, destination and recipients.",
    "ja": "数ステップで登山の準備ができます。説明を読み、同意・現在地・目的地・共有先を順に確認してください。",
    "zh": "只需几步即可准备徒步。请依次阅读说明、确认同意、位置、目的地及共享对象。",
    "fr": "Préparez la randonnée en quelques étapes : introduction, consentement, position, destination et proches.",
    "pt": "Prepare a trilha em poucos passos: explicação, consentimento, posição, destino e pessoas."
  },
  "몇 단계만 따라 하면 귀가 준비가 끝납니다. 설명을 읽고 동의·위치·목적지·공유 대상을 차례로 확인하세요.": {
    "en": "Prepare your return in a few steps. Read the introduction, then review consent, location, destination and recipients.",
    "ja": "数ステップで帰宅の準備ができます。説明を読み、同意・現在地・目的地・共有先を順に確認してください。",
    "zh": "只需几步即可准备回家。请依次阅读说明、确认同意、位置、目的地及共享对象。",
    "fr": "Préparez le retour en quelques étapes : introduction, consentement, position, destination et proches.",
    "pt": "Prepare a volta em poucos passos: explicação, consentimento, posição, destino e pessoas."
  },
  "가족·친구와 연결되어 있어도 자동으로 위치가 공개되지 않습니다. 마지막 단계에서 확인하고 시작해야 이동 기록과 공유를 시작합니다.": {
    "en": "Connecting with family or friends never shares location automatically. Recording and sharing begin only after your final confirmation.",
    "ja": "家族・友人との連携だけでは位置を公開しません。最後に確認して開始するまで移動記録と共有は始まりません。",
    "zh": "与家人朋友连接不会自动公开位置，只有最终确认开始后才启动行程记录及共享。",
    "fr": "La connexion avec les proches ne partage rien automatiquement. Enregistrement et partage commencent après confirmation finale.",
    "pt": "Conectar familiares e amigos não compartilha automaticamente. Registro e compartilhamento começam após a confirmação final."
  },
  "저장된 산행 기록이 있습니다. 새 기록은 기존 기기 기록을 교체합니다. 필요한 기록은 기존 메뉴에서 먼저 내보내세요.": {
    "en": "A saved hike exists. Starting a new record replaces it on this device. Export needed records from the existing menu first.",
    "ja": "保存済みの登山記録があります。新しい記録は端末の以前の記録を置き換えます。必要な記録を先に既存メニューから書き出してください。",
    "zh": "已有徒步记录，新记录将替换本设备旧记录，请先从原菜单导出所需记录。",
    "fr": "Une randonnée est enregistrée. Un nouveau relevé la remplace sur cet appareil. Exportez d’abord les données utiles depuis le menu existant.",
    "pt": "Há uma trilha salva. Um novo registro substitui o anterior neste aparelho. Exporte antes o necessário pelo menu existente."
  },
  "안내를 이해했습니다.": {
    "en": "I understand the introduction.",
    "ja": "案内を理解しました。",
    "zh": "我已理解说明。",
    "fr": "J’ai compris les explications.",
    "pt": "Entendi as instruções."
  },
  "개인정보 처리 안내": {
    "en": "Privacy information",
    "ja": "個人情報の取扱い",
    "zh": "隐私处理说明",
    "fr": "Informations de confidentialité",
    "pt": "Informações de privacidade"
  },
  "로그인은 Firebase 인증을 사용합니다. 이동 중 좌표·시간·경로와 계획을 기능 이용을 위해 기기 또는 서버에 저장합니다. 지도·주소 검색 서비스에는 요청 좌표나 검색어가 전달될 수 있습니다. 기록 삭제는 내 계정과 저장된 기록 메뉴에서 할 수 있습니다.": {
    "en": "Sign-in uses Firebase Authentication. Coordinates, times, routes and plans are stored on the device or server for these features. Requested coordinates or queries may be sent to map and address-search services. Delete records through My Account and Saved Records.",
    "ja": "ログインにはFirebase認証を使用します。機能のため座標・時刻・経路・計画を端末またはサーバーに保存します。地図や住所検索サービスに座標・検索語が渡る場合があります。アカウントと保存記録メニューから削除できます。",
    "zh": "登录使用Firebase验证。功能会在设备或服务器保存坐标、时间、路线和计划。地图及地址搜索服务可能接收所请求坐标或搜索词，可从账户及保存记录菜单删除记录。",
    "fr": "La connexion utilise Firebase Authentication. Coordonnées, heures, parcours et plans sont stockés localement ou sur serveur. Les services de carte et de recherche peuvent recevoir coordonnées et requêtes. Supprimez les relevés depuis le compte et les données enregistrées.",
    "pt": "O login usa Firebase Authentication. Coordenadas, horários, rotas e planos ficam no aparelho ou servidor. Serviços de mapa e busca podem receber coordenadas e consultas. Exclua registros em Minha conta e Registros salvos."
  },
  "개인정보 처리 안내를 읽고 동의합니다.": {
    "en": "I have read and agree to the privacy information.",
    "ja": "個人情報の取扱いを読み、同意します。",
    "zh": "我已阅读并同意隐私处理说明。",
    "fr": "J’ai lu et accepte ces informations de confidentialité.",
    "pt": "Li e concordo com as informações de privacidade."
  },
  "위치 이용 동의": {
    "en": "Location consent",
    "ja": "位置利用への同意",
    "zh": "位置使用同意",
    "fr": "Consentement à la localisation",
    "pt": "Consentimento de localização"
  },
  "내 위치 확인 버튼을 누를 때 기기의 위치 권한을 요청합니다. 앱 종료·절전·GPS 불량으로 기록이 중단될 수 있습니다. 상대방에게 공유하려면 이후 단계에서 직접 선택해야 합니다. 자동 구조 요청이나 현재 위치 보장은 제공하지 않습니다.": {
    "en": "Checking your location requests device permission. Closing the app, power saving or poor GPS may interrupt recording. Sharing requires your selection in a later step. No automatic rescue request or guaranteed current position is provided.",
    "ja": "現在地確認時に端末の位置権限を求めます。アプリ終了・省電力・GPS不良で記録が中断する場合があります。共有先は後のステップで選択してください。自動救助要請や現在地の保証はありません。",
    "zh": "确认位置时会请求设备定位权限。关闭应用、省电或GPS不良可能中断记录。共享需在后续步骤主动选择，不提供自动救援请求或当前位置保证。",
    "fr": "La vérification demande la permission de localisation. Fermeture, économie d’énergie ou mauvais GPS peuvent interrompre les relevés. Le partage nécessite votre choix ensuite. Aucune demande automatique de secours ni position garantie.",
    "pt": "Conferir a posição solicita permissão do aparelho. Fechamento, economia de energia ou GPS ruim podem interromper registros. Compartilhar exige escolha posterior. Não há resgate automático nem posição atual garantida."
  },
  "이번 이동의 위치 이용에 동의합니다.": {
    "en": "I consent to location use for this trip.",
    "ja": "今回の移動での位置利用に同意します。",
    "zh": "我同意本次行程使用位置。",
    "fr": "J’accepte la localisation pour ce trajet.",
    "pt": "Concordo com o uso da localização neste percurso."
  },
  "아래 버튼을 눌러 위치 권한을 허용하고 GPS 위치를 확인하세요. 다음 단계로 가기 전에 좌표와 정확도를 확인합니다.": {
    "en": "Tap below, allow location permission and check the GPS fix. Review coordinates and accuracy before continuing.",
    "ja": "下のボタンで位置権限を許可し、GPS位置を確認してください。次に進む前に座標と精度を確認します。",
    "zh": "点击下方按钮允许位置权限并检查GPS，继续前请核对坐标和精度。",
    "fr": "Appuyez ci-dessous, autorisez la localisation et vérifiez le GPS. Contrôlez coordonnées et précision avant de continuer.",
    "pt": "Toque abaixo, permita localização e confira o GPS. Verifique coordenadas e precisão antes de continuar."
  },
  "내 위치 다시 확인": {
    "en": "Check my location again",
    "ja": "現在地を再確認",
    "zh": "重新确认位置",
    "fr": "Vérifier à nouveau ma position",
    "pt": "Conferir posição novamente"
  },
  "내 위치 확인 완료": {
    "en": "Location checked",
    "ja": "現在地確認済み",
    "zh": "位置已确认",
    "fr": "Position vérifiée",
    "pt": "Posição conferida"
  },
  "GPS 정확도 약 {meters}m": {
    "en": "GPS accuracy about {meters} m",
    "ja": "GPS精度は約{meters}m",
    "zh": "GPS精度约{meters}米",
    "fr": "Précision GPS : environ {meters} m",
    "pt": "Precisão GPS: cerca de {meters} m"
  },
  "산행 목적지를 검색하거나 지도에서 누르세요. 정해진 목적지가 없으면 경로만 기록을 선택할 수 있습니다.": {
    "en": "Search for a hiking destination or tap the map. If there is no fixed destination, choose route recording only.",
    "ja": "登山の目的地を検索するか地図で選んでください。目的地が決まっていなければ経路記録のみを選べます。",
    "zh": "搜索徒步目的地或点击地图；没有固定目的地时可选择仅记录路线。",
    "fr": "Recherchez la destination de randonnée ou touchez la carte. Sans destination fixe, choisissez le relevé du parcours seul.",
    "pt": "Busque o destino da trilha ou toque no mapa. Sem destino fixo, escolha apenas registrar a rota."
  },
  "귀가할 주소나 장소를 검색한 뒤 지도에서 목적지가 맞는지 확인하세요. 지도에서 원하는 지점을 직접 누를 수도 있습니다.": {
    "en": "Search for your return address or place and verify it on the map. You may also tap a point directly.",
    "ja": "帰宅先の住所・場所を検索し、地図で確認してください。地図の地点を直接選ぶこともできます。",
    "zh": "搜索回家地址或地点后在地图核对，也可直接点击地图选择。",
    "fr": "Recherchez l’adresse ou le lieu de retour et vérifiez sur la carte. Vous pouvez aussi sélectionner un point directement.",
    "pt": "Busque o endereço ou local de volta e confira no mapa. Também pode tocar diretamente em um ponto."
  },
  "주소 또는 장소명": {
    "en": "Address or place name",
    "ja": "住所または場所名",
    "zh": "地址或地点名",
    "fr": "Adresse ou nom du lieu",
    "pt": "Endereço ou nome do local"
  },
  "목적지 검색": {
    "en": "Search destination",
    "ja": "目的地を検索",
    "zh": "搜索目的地",
    "fr": "Rechercher la destination",
    "pt": "Buscar destino"
  },
  "목적지 없이 경로만 기록": {
    "en": "Record route without a destination",
    "ja": "目的地なしで経路のみ記録",
    "zh": "无目的地，仅记录路线",
    "fr": "Relever le parcours sans destination",
    "pt": "Registrar rota sem destino"
  },
  "귀환 예정시간 변경": {
    "en": "Change planned return",
    "ja": "帰還予定時刻を変更",
    "zh": "修改预计返回时间",
    "fr": "Modifier le retour prévu",
    "pt": "Alterar retorno previsto"
  },
  "이번 이동을 가족·친구와 공유할지 선택하세요. 공유하지 않아도 내 이동 기록을 시작할 수 있습니다.": {
    "en": "Choose whether to share this trip with family or friends. You can record your trip without sharing.",
    "ja": "今回の移動を家族・友人に共有するか選んでください。共有せず自分の移動記録だけを開始できます。",
    "zh": "选择是否与家人朋友共享本次行程，不共享也可开始个人记录。",
    "fr": "Choisissez de partager ou non avec les proches. Vous pouvez enregistrer sans partager.",
    "pt": "Escolha compartilhar ou não com familiares e amigos. Pode registrar sem compartilhar."
  },
  "가족·친구에게 위치 공유": {
    "en": "Share location with family & friends",
    "ja": "家族・友人に位置を共有",
    "zh": "与家人朋友共享位置",
    "fr": "Partager la position avec les proches",
    "pt": "Compartilhar posição com familiares e amigos"
  },
  "마지막 기록 조회 허용: {count}명": {
    "en": "Last-record access: {count} people",
    "ja": "最終記録の閲覧許可：{count}人",
    "zh": "允许查看最后记录：{count}人",
    "fr": "Accès au dernier relevé : {count} personnes",
    "pt": "Acesso ao último registro: {count} pessoas"
  },
  "사람 추가·모임 관리": {
    "en": "Add people · Manage groups",
    "ja": "連絡先追加・グループ管理",
    "zh": "添加联系人·管理分组",
    "fr": "Ajouter des proches · Gérer les groupes",
    "pt": "Adicionar pessoas · Gerenciar grupos"
  },
  "새 사람은 상대방이 초대를 수락해야 선택할 수 있습니다. 모임은 연결된 사람을 묶어 고르는 기능입니다.": {
    "en": "New people can be selected after accepting your invitation. Groups let you select connected people together.",
    "ja": "新しい相手は招待承認後に選べます。グループは連携済みの相手をまとめて選ぶ機能です。",
    "zh": "新联系人接受邀请后才可选择，分组用于一起选择已连接的人。",
    "fr": "Un nouveau proche doit accepter l’invitation. Les groupes permettent une sélection commune de proches connectés.",
    "pt": "Novas pessoas precisam aceitar o convite. Grupos permitem selecionar pessoas conectadas juntas."
  },
  "아래 내용을 확인한 뒤 시작하세요. 이전을 누르면 설정을 바꿀 수 있습니다.": {
    "en": "Review below, then start. Use Back to change settings.",
    "ja": "下の内容を確認して開始してください。前へ戻ると設定を変更できます。",
    "zh": "请核对以下内容后开始，点击上一步可修改。",
    "fr": "Vérifiez ci-dessous puis démarrez. Retour permet de modifier.",
    "pt": "Confira abaixo e inicie. Voltar permite alterar as opções."
  },
  "목적지": {
    "en": "Destination",
    "ja": "目的地",
    "zh": "目的地",
    "fr": "Destination",
    "pt": "Destino"
  },
  "공유 없이 내 기록만 시작": {
    "en": "Start my record without sharing",
    "ja": "共有せず自分の記録のみ開始",
    "zh": "不共享，仅开始个人记录",
    "fr": "Enregistrer sans partager",
    "pt": "Registrar sem compartilhar"
  },
  "뒤로 가거나 취소하면 이동·공유는 시작되지 않습니다. 이미 별도로 보낸 초대나 수락은 유지됩니다.": {
    "en": "Going back or cancelling does not start recording or sharing. Invitations already sent or accepted separately remain.",
    "ja": "戻る・キャンセルでは移動記録と共有は始まりません。別途送信・承認した招待は残ります。",
    "zh": "返回或取消不会启动记录或共享，已单独发送或接受的邀请会保留。",
    "fr": "Revenir ou annuler ne démarre ni relevé ni partage. Les invitations déjà envoyées ou acceptées restent.",
    "pt": "Voltar ou cancelar não inicia registro nem compartilhamento. Convites já enviados ou aceitos permanecem."
  },
  "산행 시작 도우미": {
    "en": "Hiking setup",
    "ja": "登山開始ガイド",
    "zh": "徒步开始向导",
    "fr": "Préparer la randonnée",
    "pt": "Preparar trilha"
  },
  "귀가 시작 도우미": {
    "en": "Safe return setup",
    "ja": "帰宅開始ガイド",
    "zh": "回家开始向导",
    "fr": "Préparer le retour",
    "pt": "Preparar volta"
  },
  "이전": {
    "en": "Back",
    "ja": "前へ",
    "zh": "上一步",
    "fr": "Retour",
    "pt": "Voltar"
  },
  "확인하고 시작": {
    "en": "Confirm and start",
    "ja": "確認して開始",
    "zh": "确认并开始",
    "fr": "Confirmer et démarrer",
    "pt": "Confirmar e iniciar"
  },
  "다음": {
    "en": "Next",
    "ja": "次へ",
    "zh": "下一步",
    "fr": "Suivant",
    "pt": "Avançar"
  },
  "{step} / 6 · {title}": {
    "en": "{step} / 6 · {title}",
    "ja": "{step} / 6・{title}",
    "zh": "{step} / 6 · {title}",
    "fr": "{step} / 6 · {title}",
    "pt": "{step} / 6 · {title}"
  },
  "준비를 완료하지 못했습니다. 연결 상태와 권한을 확인한 뒤 다시 시작하세요.": {
    "en": "Setup could not finish. Check connection and permissions, then start again.",
    "ja": "準備を完了できませんでした。通信と権限を確認して再度開始してください。",
    "zh": "无法完成准备，请检查网络和权限后重新开始。",
    "fr": "Préparation inachevée. Vérifiez connexion et permissions puis recommencez.",
    "pt": "Não foi possível concluir. Confira conexão e permissões e tente novamente."
  },
  "이동 기록은 시작했지만 공유 설정은 확인하지 못했습니다. 공유 대상 변경 또는 위치 공유에서 다시 확인하세요.": {
    "en": "Recording started, but sharing setup is unconfirmed. Check Change recipients or Location sharing.",
    "ja": "移動記録は開始しましたが共有設定を確認できません。共有先変更または位置共有で再確認してください。",
    "zh": "行程记录已开始，但共享设置未确认。请在更改共享对象或位置共享中检查。",
    "fr": "Le relevé a démarré mais le partage n’est pas confirmé. Vérifiez les destinataires ou le partage de position.",
    "pt": "O registro iniciou, mas compartilhar não foi confirmado. Confira destinatários ou compartilhamento de posição."
  },
  "설정을 적용하고 있습니다. 잠시 기다려주세요.": {
    "en": "Applying your setup. Please wait.",
    "ja": "設定を適用しています。しばらくお待ちください。",
    "zh": "正在应用设置，请稍候。",
    "fr": "Application des réglages. Patientez.",
    "pt": "Aplicando as opções. Aguarde."
  },
  "가족·친구 초대": {
    "en": "Invite family & friends",
    "ja": "家族・友人を招待",
    "zh": "邀请家人和朋友",
    "fr": "Inviter des proches",
    "pt": "Convidar família e amigos"
  },
  "링크나 QR로 쉽게 연결하세요.": {
    "en": "Connect easily with a link or QR code.",
    "ja": "リンクやQRで簡単につながりましょう。",
    "zh": "通过链接或二维码轻松连接。",
    "fr": "Connectez-vous par lien ou QR code.",
    "pt": "Conecte-se por link ou código QR."
  },
  "휴대폰 공유창에서 WhatsApp·LINE·문자·이메일 등 설치된 앱을 선택할 수 있습니다. 연결 후에도 위치 공유는 직접 시작해야 합니다.": {
    "en": "Choose an installed app such as WhatsApp, LINE, SMS or email from your phone’s share sheet. Location sharing still requires you to start it.",
    "ja": "共有メニューでWhatsApp・LINE・SMS・メールなどを選べます。接続後も位置共有は自分で開始します。",
    "zh": "可在手机分享菜单选择WhatsApp、LINE、短信或邮件等已安装应用。连接后仍需主动开启位置共享。",
    "fr": "Choisissez WhatsApp, LINE, SMS ou e-mail dans le menu de partage. Le partage de position doit être démarré manuellement.",
    "pt": "Escolha WhatsApp, LINE, SMS ou e-mail no menu de compartilhamento. A localização só é compartilhada quando você iniciar."
  },
  "연결하려면 로그인과 이메일 인증이 필요합니다. 받은 초대는 로그인 후에도 유지됩니다.": {
    "en": "Sign in and verify your email to connect. Your invitation is kept while you sign in.",
    "ja": "接続にはログインとメール認証が必要です。受け取った招待はログイン後も保持されます。",
    "zh": "连接需要登录并验证邮箱。登录后收到的邀请仍会保留。",
    "fr": "Connectez-vous et vérifiez votre e-mail. L’invitation est conservée pendant la connexion.",
    "pt": "Entre e verifique seu e-mail. O convite é mantido durante o login."
  },
  "로그인·인증 확인": {
    "en": "Sign in / verify email",
    "ja": "ログイン・認証確認",
    "zh": "登录／验证邮箱",
    "fr": "Connexion / vérification",
    "pt": "Entrar / verificar e-mail"
  },
  "내 초대 QR": {
    "en": "My invitation QR",
    "ja": "自分の招待QR",
    "zh": "我的邀请二维码",
    "fr": "Mon QR d’invitation",
    "pt": "Meu QR de convite"
  },
  "상대방이 스캔한 뒤 연결 요청을 보내면 내가 승인합니다. QR에는 내 연결 ID가 포함됩니다.": {
    "en": "After scanning, the other person sends a request for you to approve. The QR contains your connection ID.",
    "ja": "相手がスキャンして接続申請を送ると、自分が承認します。QRには接続IDが含まれます。",
    "zh": "对方扫码后发送连接请求，由您批准。二维码包含您的连接ID。",
    "fr": "Après le scan, l’autre personne envoie une demande que vous approuvez. Le QR contient votre identifiant de connexion.",
    "pt": "Após escanear, a outra pessoa envia uma solicitação para você aprovar. O QR contém seu ID de conexão."
  },
  "초대 링크 보내기": {
    "en": "Share invitation link",
    "ja": "招待リンクを送る",
    "zh": "发送邀请链接",
    "fr": "Partager le lien d’invitation",
    "pt": "Compartilhar link de convite"
  },
  "초대 링크 복사": {
    "en": "Copy invitation link",
    "ja": "招待リンクをコピー",
    "zh": "复制邀请链接",
    "fr": "Copier le lien",
    "pt": "Copiar link de convite"
  },
  "초대 링크를 복사했습니다.": {
    "en": "Invitation link copied.",
    "ja": "招待リンクをコピーしました。",
    "zh": "邀请链接已复制。",
    "fr": "Lien d’invitation copié.",
    "pt": "Link de convite copiado."
  },
  "오르큐브 안심동행에서 연결해요. 링크를 열고 로그인한 뒤 연결 요청을 보내주세요. 위치는 자동 공유되지 않습니다.": {
    "en": "Connect with me on ORQUBE Safe Companion. Open this link, sign in and send a connection request. Your location is not shared automatically.",
    "ja": "ORQUBEでつながりましょう。リンクを開いてログインし、接続申請を送ってください。位置は自動共有されません。",
    "zh": "在ORQUBE安心同行中连接吧。打开链接登录后发送连接请求。位置不会自动共享。",
    "fr": "Retrouvez-moi sur ORQUBE Safe Companion. Ouvrez ce lien, connectez-vous et envoyez une demande. Votre position n’est pas partagée automatiquement.",
    "pt": "Conecte-se comigo no ORQUBE Safe Companion. Abra o link, entre e envie uma solicitação. Sua localização não é compartilhada automaticamente."
  },
  "상대방 QR 스캔": {
    "en": "Scan someone’s QR",
    "ja": "相手のQRをスキャン",
    "zh": "扫描对方二维码",
    "fr": "Scanner le QR d’un proche",
    "pt": "Escanear QR de outra pessoa"
  },
  "초대 QR 스캔": {
    "en": "Scan invitation QR",
    "ja": "招待QRをスキャン",
    "zh": "扫描邀请二维码",
    "fr": "Scanner un QR d’invitation",
    "pt": "Escanear QR de convite"
  },
  "상대방의 초대 QR을 네모 안에 비춰주세요.": {
    "en": "Point the camera at the other person’s invitation QR.",
    "ja": "相手の招待QRにカメラを向けてください。",
    "zh": "请将摄像头对准对方的邀请二维码。",
    "fr": "Visez le QR d’invitation de l’autre personne.",
    "pt": "Aponte a câmera para o QR de convite da outra pessoa."
  },
  "카메라를 사용할 수 없습니다. 카메라 권한을 확인하거나 뒤로 가서 초대 링크를 붙여넣으세요.": {
    "en": "Camera unavailable. Check camera permission or go back and paste the invitation link.",
    "ja": "カメラを使えません。権限を確認するか、戻って招待リンクを貼り付けてください。",
    "zh": "无法使用摄像头。请检查权限或返回粘贴邀请链接。",
    "fr": "Caméra indisponible. Vérifiez l’autorisation ou revenez coller le lien d’invitation.",
    "pt": "Câmera indisponível. Verifique a permissão ou volte e cole o link de convite."
  },
  "오르큐브 초대 QR이 아닙니다. 올바른 QR을 스캔하세요.": {
    "en": "This is not an ORQUBE invitation QR. Scan a valid invitation.",
    "ja": "ORQUBEの招待QRではありません。正しいQRをスキャンしてください。",
    "zh": "这不是ORQUBE邀请二维码。请扫描有效二维码。",
    "fr": "Ce QR n’est pas une invitation ORQUBE. Scannez une invitation valide.",
    "pt": "Este QR não é um convite ORQUBE. Escaneie um convite válido."
  },
  "스캔은 연결 정보를 읽기만 합니다. 확인 전에는 요청이나 위치 공유가 시작되지 않습니다.": {
    "en": "Scanning only reads the connection details. No request or location sharing starts before confirmation.",
    "ja": "スキャンは接続情報を読むだけです。確認前に申請や位置共有は始まりません。",
    "zh": "扫码仅用于读取连接信息。确认前不会发送请求或共享位置。",
    "fr": "Le scan lit uniquement les informations de connexion. Aucune demande ni aucun partage ne démarre avant confirmation.",
    "pt": "A leitura só obtém os dados de conexão. Nenhuma solicitação ou localização é compartilhada antes da confirmação."
  },
  "받은 초대 링크 또는 연결 ID": {
    "en": "Invitation link or connection ID",
    "ja": "受け取った招待リンクまたは接続ID",
    "zh": "收到的邀请链接或连接ID",
    "fr": "Lien reçu ou identifiant de connexion",
    "pt": "Link recebido ou ID de conexão"
  },
  "받은 초대 확인": {
    "en": "Review invitation",
    "ja": "招待を確認",
    "zh": "查看邀请",
    "fr": "Vérifier l’invitation",
    "pt": "Verificar convite"
  },
  "올바른 오르큐브 초대 링크 또는 연결 ID를 입력하세요.": {
    "en": "Enter a valid ORQUBE invitation link or connection ID.",
    "ja": "有効なORQUBE招待リンクまたは接続IDを入力してください。",
    "zh": "请输入有效的ORQUBE邀请链接或连接ID。",
    "fr": "Saisissez un lien d’invitation ORQUBE ou un identifiant valide.",
    "pt": "Insira um link de convite ORQUBE ou ID de conexão válido."
  },
  "연결할 사람 확인": {
    "en": "Confirm the person",
    "ja": "接続する相手を確認",
    "zh": "确认连接对象",
    "fr": "Confirmer la personne",
    "pt": "Confirmar a pessoa"
  },
  "링크만으로 상대방 신원을 보증하지 않습니다. 알고 있는 사람에게 받은 초대인지 확인하세요.": {
    "en": "A link does not verify someone’s identity. Confirm that this invitation came from someone you know.",
    "ja": "リンクは相手の身元を保証しません。知っている人からの招待か確認してください。",
    "zh": "链接不能保证对方身份。请确认邀请来自您认识的人。",
    "fr": "Un lien ne garantit pas l’identité. Vérifiez que l’invitation vient d’une personne connue.",
    "pt": "Um link não garante a identidade. Confirme que o convite veio de alguém conhecido."
  },
  "연결 요청·수락": {
    "en": "Request / accept connection",
    "ja": "接続申請・承認",
    "zh": "请求／接受连接",
    "fr": "Demander / accepter la connexion",
    "pt": "Solicitar / aceitar conexão"
  },
  "설치된 앱에서 열기": {
    "en": "Open installed app",
    "ja": "インストール済みアプリで開く",
    "zh": "在已安装应用中打开",
    "fr": "Ouvrir l’application installée",
    "pt": "Abrir no aplicativo instalado"
  },
  "설치된 앱을 열지 못했습니다. 이 화면에서 계속하거나 앱에서 링크를 붙여넣으세요.": {
    "en": "Could not open the installed app. Continue here or paste the link in the app.",
    "ja": "アプリを開けませんでした。この画面で続けるか、アプリにリンクを貼り付けてください。",
    "zh": "无法打开已安装应用。请在此继续或在应用内粘贴链接。",
    "fr": "Impossible d’ouvrir l’application. Continuez ici ou collez le lien dans l’application.",
    "pt": "Não foi possível abrir o aplicativo. Continue aqui ou cole o link no aplicativo."
  },
  "초대 닫기": {
    "en": "Dismiss invitation",
    "ja": "招待を閉じる",
    "zh": "关闭邀请",
    "fr": "Fermer l’invitation",
    "pt": "Fechar convite"
  },
  "내 초대 링크입니다. 상대방에게 보내주세요.": {
    "en": "This is your own invitation. Send it to the other person.",
    "ja": "自分の招待リンクです。相手に送ってください。",
    "zh": "这是您自己的邀请链接。请发送给对方。",
    "fr": "C’est votre propre invitation. Envoyez-la à l’autre personne.",
    "pt": "Este é seu próprio convite. Envie-o à outra pessoa."
  },
  "상대방을 알아볼 표시 이름을 입력하세요.": {
    "en": "Enter a name to recognize this person.",
    "ja": "相手が分かる表示名を入力してください。",
    "zh": "请输入便于识别对方的显示名称。",
    "fr": "Saisissez un nom pour reconnaître cette personne.",
    "pt": "Insira um nome para reconhecer esta pessoa."
  },
  "이미 연결된 사람입니다. 이름과 관계를 저장했습니다.": {
    "en": "Already connected. Name and relationship saved.",
    "ja": "接続済みです。名前と関係を保存しました。",
    "zh": "已经连接。名称和关系已保存。",
    "fr": "Déjà connecté. Nom et relation enregistrés.",
    "pt": "Já conectado. Nome e relação salvos."
  },
  "연결되었습니다. 이동을 시작할 때 공유할 사람으로 선택하세요.": {
    "en": "Connected. Select this person when starting location sharing.",
    "ja": "接続しました。移動開始時に共有相手として選んでください。",
    "zh": "已连接。开始移动时请选择此人作为共享对象。",
    "fr": "Connexion établie. Sélectionnez cette personne au début du partage.",
    "pt": "Conectado. Selecione esta pessoa ao iniciar o compartilhamento."
  },
  "연결 요청을 보냈습니다. 상대방의 받은 초대에서 승인하면 연결됩니다.": {
    "en": "Request sent. The other person must approve it under Received invitations.",
    "ja": "接続申請を送りました。相手が「受け取った招待」で承認すると接続します。",
    "zh": "连接请求已发送。对方在收到的邀请中批准后即可连接。",
    "fr": "Demande envoyée. L’autre personne doit l’approuver dans les invitations reçues.",
    "pt": "Solicitação enviada. A outra pessoa deve aprová-la nos convites recebidos."
  },
  "처리하지 못했습니다. 로그인·이메일 인증·인터넷 연결을 확인한 뒤 다시 시도하세요.": {
    "en": "Could not complete this action. Check sign-in, email verification and internet access, then retry.",
    "ja": "処理できませんでした。ログイン・メール認証・通信を確認して再試行してください。",
    "zh": "无法完成操作。请检查登录、邮箱验证和网络后重试。",
    "fr": "Action impossible. Vérifiez la connexion au compte, l’e-mail et Internet, puis réessayez.",
    "pt": "Não foi possível concluir. Verifique login, e-mail e internet e tente novamente."
  },
  "연결 ID 직접 입력": {
    "en": "Enter connection ID manually",
    "ja": "接続IDを直接入力",
    "zh": "手动输入连接ID",
    "fr": "Saisir l’identifiant manuellement",
    "pt": "Inserir ID de conexão manualmente"
  },
  "상세 메뉴": {
    "en": "Details & settings",
    "ja": "詳細メニュー",
    "zh": "详细菜单",
    "fr": "Détails et réglages",
    "pt": "Detalhes e ajustes"
  },
  "이동 지도 보기": {
    "en": "Open trip map",
    "ja": "移動マップを表示",
    "zh": "查看移动地图",
    "fr": "Voir la carte du trajet",
    "pt": "Ver mapa do trajeto"
  },
  "GPS 갱신 지연 · 마지막 위치": {
    "en": "GPS delayed · Last location",
    "ja": "GPS更新遅延・最終位置",
    "zh": "GPS更新延迟 · 最后位置",
    "fr": "GPS retardé · Dernière position",
    "pt": "GPS atrasado · Última posição"
  },
  "이동 기록 중 · 기기 GPS": {
    "en": "Recording trip · Device GPS",
    "ja": "移動を記録中・端末GPS",
    "zh": "正在记录移动 · 设备GPS",
    "fr": "Trajet en cours · GPS du téléphone",
    "pt": "Registrando trajeto · GPS do aparelho"
  },
  "공유 켜짐": {
    "en": "Sharing on",
    "ja": "共有オン",
    "zh": "共享已开启",
    "fr": "Partage activé",
    "pt": "Compartilhamento ativo"
  },
  "나만 기록": {
    "en": "Private recording",
    "ja": "自分だけに記録",
    "zh": "仅自己记录",
    "fr": "Enregistrement privé",
    "pt": "Registro privado"
  },
  "출발점": {
    "en": "Start point",
    "ja": "出発点",
    "zh": "出发点",
    "fr": "Point de départ",
    "pt": "Ponto de partida"
  },
  "마지막 GPS 위치": {
    "en": "Last GPS location",
    "ja": "最終GPS位置",
    "zh": "最后GPS位置",
    "fr": "Dernière position GPS",
    "pt": "Última posição GPS"
  },
  "내 위치 따라가는 중": {
    "en": "Following my location",
    "ja": "現在地を追従中",
    "zh": "正在跟随我的位置",
    "fr": "Suivi de ma position",
    "pt": "Seguindo minha localização"
  },
  "내 위치 따라가기": {
    "en": "Follow my location",
    "ja": "現在地を追従",
    "zh": "跟随我的位置",
    "fr": "Suivre ma position",
    "pt": "Seguir minha localização"
  },
  "전체 동선 보기": {
    "en": "Show full route",
    "ja": "全移動経路を表示",
    "zh": "查看完整轨迹",
    "fr": "Voir tout le trajet",
    "pt": "Ver trajeto completo"
  },
  "이동 시간": {
    "en": "Elapsed time",
    "ja": "経過時間",
    "zh": "移动时间",
    "fr": "Temps écoulé",
    "pt": "Tempo decorrido"
  },
  "이동 거리": {
    "en": "Distance travelled",
    "ja": "移動距離",
    "zh": "移动距离",
    "fr": "Distance parcourue",
    "pt": "Distância percorrida"
  },
  "목적지 직선거리": {
    "en": "Straight-line distance",
    "ja": "目的地までの直線距離",
    "zh": "距目的地直线距离",
    "fr": "Distance à vol d’oiseau",
    "pt": "Distância em linha reta"
  },
  "공유 종료 예정": {
    "en": "Sharing ends",
    "ja": "共有終了予定",
    "zh": "预计共享结束",
    "fr": "Fin du partage prévue",
    "pt": "Fim previsto do compartilhamento"
  },
  "출발점 좌표: {lat}, {lng}": {
    "en": "Start coordinates: {lat}, {lng}",
    "ja": "出発点座標: {lat}, {lng}",
    "zh": "出发点坐标：{lat}, {lng}",
    "fr": "Coordonnées de départ : {lat}, {lng}",
    "pt": "Coordenadas de partida: {lat}, {lng}"
  },
  "GPS 시각": {
    "en": "GPS fix time",
    "ja": "GPS測位時刻",
    "zh": "GPS定位时间",
    "fr": "Heure du relevé GPS",
    "pt": "Horário da leitura GPS"
  },
  "없음": {
    "en": "None",
    "ja": "なし",
    "zh": "无",
    "fr": "Aucun",
    "pt": "Nenhum"
  },
  "변경": {
    "en": "Change",
    "ja": "変更",
    "zh": "更改",
    "fr": "Modifier",
    "pt": "Alterar"
  },
  "위치는 다른 사람에게 전송하지 않습니다.": {
    "en": "Location is not sent to other people.",
    "ja": "位置は他の人に送信しません。",
    "zh": "位置不会发送给其他人。",
    "fr": "La position n’est pas envoyée à d’autres personnes.",
    "pt": "A localização não é enviada a outras pessoas."
  },
  "서버 전송 실패 · 상대방은 이전 위치를 볼 수 있습니다.": {
    "en": "Server upload failed · Others may see an older location.",
    "ja": "サーバー送信失敗・相手には以前の位置が表示される場合があります。",
    "zh": "服务器上传失败 · 对方可能看到旧位置。",
    "fr": "Envoi au serveur échoué · Une ancienne position peut être affichée.",
    "pt": "Falha no envio · Outras pessoas podem ver uma posição anterior."
  },
  "서버 전송 확인 중 · 수신 완료와 다릅니다.": {
    "en": "Checking server upload · Not a receipt confirmation.",
    "ja": "サーバー送信確認中・相手の受信完了ではありません。",
    "zh": "正在确认服务器上传 · 不代表对方已收到。",
    "fr": "Vérification de l’envoi · Réception non confirmée.",
    "pt": "Verificando envio · Não confirma o recebimento."
  },
  "서버 저장 확인: {time} · 상대방 수신 여부는 별도입니다.": {
    "en": "Server save confirmed: {time} · Recipient delivery is separate.",
    "ja": "サーバー保存確認: {time}・相手の受信確認とは別です。",
    "zh": "服务器保存确认：{time} · 对方接收状态另行确认。",
    "fr": "Enregistrement serveur confirmé : {time} · Réception non confirmée.",
    "pt": "Registro no servidor confirmado: {time} · Recebimento não confirmado."
  },
  "이동 종료": {
    "en": "End trip",
    "ja": "移動終了",
    "zh": "结束移动",
    "fr": "Terminer le trajet",
    "pt": "Encerrar trajeto"
  },
  "이동을 종료할까요?": {
    "en": "End this trip?",
    "ja": "移動を終了しますか？",
    "zh": "结束本次移动？",
    "fr": "Terminer ce trajet ?",
    "pt": "Encerrar este trajeto?"
  },
  "이 기기의 이동 기록과 위치 공유를 종료합니다. 오프라인이면 서버 반영이 지연될 수 있습니다.": {
    "en": "Stops trip recording and location sharing on this device. Server updates may be delayed offline.",
    "ja": "この端末の移動記録と位置共有を終了します。オフラインではサーバー反映が遅れる場合があります。",
    "zh": "停止此设备的移动记录和位置共享。离线时服务器更新可能延迟。",
    "fr": "Arrête l’enregistrement et le partage sur ce téléphone. La mise à jour du serveur peut être retardée hors ligne.",
    "pt": "Encerra o registro e o compartilhamento neste aparelho. A atualização do servidor pode atrasar sem internet."
  },
  "처리하지 못했습니다. 연결 상태를 확인하고 다시 시도하세요.": {
    "en": "Could not complete this action. Check your connection and retry.",
    "ja": "処理できませんでした。接続を確認して再試行してください。",
    "zh": "操作未完成。请检查连接后重试。",
    "fr": "Action impossible. Vérifiez la connexion et réessayez.",
    "pt": "Não foi possível concluir. Verifique a conexão e tente novamente."
  },
  "산행 시작하고 지도 보기": {
    "en": "Start hike and open map",
    "ja": "登山を開始して地図を表示",
    "zh": "开始登山并查看地图",
    "fr": "Démarrer la randonnée et voir la carte",
    "pt": "Iniciar trilha e abrir mapa"
  },
  "귀가 시작하고 지도 보기": {
    "en": "Start return and open map",
    "ja": "帰宅を開始して地図を表示",
    "zh": "开始归家并查看地图",
    "fr": "Démarrer le retour et voir la carte",
    "pt": "Iniciar retorno e abrir mapa"
  },
  "SOS · 마지막 GPS 좌표": {
    "en": "SOS · Last GPS coordinates",
    "ja": "SOS・最終GPS座標",
    "zh": "SOS · 最后GPS坐标",
    "fr": "SOS · Dernières coordonnées GPS",
    "pt": "SOS · Últimas coordenadas GPS"
  },
  "자동 신고나 구조 요청 전송이 아닙니다. 표시된 GPS 시각을 확인하고 필요하면 현지 긴급전화로 직접 연락하세요.": {
    "en": "This does not automatically call or alert rescue services. Check the GPS time and contact local emergency services yourself if needed.",
    "ja": "自動通報や救助要請の送信ではありません。GPS時刻を確認し、必要なら現地の緊急窓口へ直接連絡してください。",
    "zh": "此功能不会自动报警或发送救援请求。请检查GPS时间，必要时自行联系当地紧急服务。",
    "fr": "Aucun appel ni envoi automatique aux secours. Vérifiez l’heure GPS et contactez directement les secours locaux si nécessaire.",
    "pt": "Não aciona nem avisa o resgate automaticamente. Confira o horário GPS e contate os serviços de emergência locais se necessário."
  },
  "SOS 좌표 보내기": {
    "en": "Share SOS coordinates",
    "ja": "SOS座標を送る",
    "zh": "发送SOS坐标",
    "fr": "Partager les coordonnées SOS",
    "pt": "Compartilhar coordenadas SOS"
  }
};

const companionEnglishPairs = <String,String>{
  "길을 잃었습니다": "I am lost",
  "부상을 입었습니다": "I am injured",
  "장비 문제가 발생했습니다": "Equipment problem",
  "차량 지원이 필요합니다": "Vehicle assistance needed",
  "기타 긴급 상황": "Other emergency",
  "기기의 위치 서비스를 먼저 켜주세요.": "Turn on the device location service first.",
  "현재 위치를 사용하려면 위치 권한이 필요합니다.": "Location permission is required to use your current location.",
  "설정에서 ORQUBE의 위치 권한을 허용해주세요.": "Allow ORQUBE location permission in Settings.",
  "현재 위치를 확인하지 못했습니다:": "Could not get current location:",
  "로그인 후 경기장을 등록할 수 있습니다.": "Sign in to register a field.",
  "현재 위치를 경기장으로 등록": "Register Current Location as Field",
  "경기장 이름": "Field name",
  "주소 또는 지역": "Address or region",
  "시설 설명·주차·안전수칙": "Facilities · parking · safety rules",
  "위도": "Latitude",
  "경도": "Longitude",
  "취소": "Cancel",
  "경기장 이름을 2자 이상 입력해주세요.": "Enter at least 2 characters for the field name.",
  "등록": "Register",
  "경기장이 등록되었습니다. 관리자 승인 전에는 등록자에게만 표시될 수 있습니다.": "The field was registered. Before admin approval, it may be visible only to you.",
  "경기장 등록 실패:": "Field registration failed:",
  "오프라인 지도 저장은 모바일 앱에서 사용할 수 있습니다.": "Offline map saving is available in the mobile app.",
  "지도 화면을 아직 저장할 수 없습니다. 잠시 후 다시 눌러주세요.": "The map is not ready to save yet. Try again shortly.",
  "지도 이미지 저장에 실패했습니다.": "Failed to save the map image.",
  "오프라인 지도 저장에 실패했습니다.": "Failed to save the offline map.",
  "현재 보이는 지도를 오프라인 안전지도로 저장했습니다.": "The visible map was saved for offline safety use.",
  "오프라인 지도 저장 중 오류가 발생했습니다.": "An error occurred while saving the offline map.",
  "저장된 오프라인 지도를 삭제했습니다.": "The saved offline map was deleted.",
  "지도 미저장": "Map not saved",
  "로그인 후 보호자를 설정할 수 있습니다.": "Sign in to set a guardian.",
  "보호자 설정": "Guardian Setup",
  "보호자 이름": "Guardian name",
  "보호자 연락처": "Guardian contact",
  "전화번호 또는 이메일": "Phone number or email",
  "보호자 정보는 안전산행 세션에만 연결되며, 산행 위치 공유를 시작할 때 함께 기록됩니다.": "Guardian details are linked to Safe Hiking and recorded with the hiking session when sharing starts.",
  "이름과 연락처를 모두 입력해 주세요.": "Enter both name and contact.",
  "저장": "Save",
  "보호자 설정을 저장했습니다.": "Guardian setup saved.",
  "보호자 정보는 현재 화면에 저장되었습니다. 네트워크 연결 후 서버 저장을 다시 시도해 주세요.": "Guardian details are kept on this screen. Try saving again after network connectivity returns.",
  "미설정": "Not set",
  "오늘": "Today",
  "귀환 예정시간은 현재 시각 이후로 설정해 주세요.": "Set the planned return time after the current time.",
  "귀환 예정시간을 설정했습니다:": "Planned return time set:",
  "보호자": "Guardian",
  "현재 위치:": "Current location:",
  "진행 중인 안전산행이 없습니다.": "There is no active Safe Hiking session.",
  "안전하게 하산했습니다": "I Arrived Safely",
  "산행을 안전하게 마쳤습니까? 확인하면 위치 공유와 GPS 세션이 함께 종료되고 안전 하산 상태가 기록됩니다.": "Did you finish the hike safely? Confirming stops location sharing and GPS tracking and records a safe completion.",
  "안전 하산 확인": "Confirm Safe Arrival",
  "안전 하산으로 기록하고 산행을 종료했습니다.": "Safe arrival recorded and the hiking session has ended.",
  "로그인 후 안전 위치 공유를 사용할 수 있습니다.": "Sign in to use safety location sharing.",
  "이동 종료까지 보호자 위치 공유": "Share Until Trip Ends",
  "안전 위치 공유": "Safety Location Sharing",
  "현재 위치와 최근 이동 경로를 서버에 저장하고, 보호자 연결 화면에서 내가 승인한 계정에 공개합니다. 전화번호만으로 조회할 수 없습니다. 이동 종료 또는 공유 중지 시 접근을 차단합니다. 인터넷 단절 시 종료 반영이 지연될 수 있으며 마지막 갱신 2분 뒤 보호자 조회가 만료됩니다.": "Your location will be shared until the hike is ended or you tap “I Arrived Safely.” GPS recording continues offline, but remote delivery can be delayed until connectivity returns.",
  "현재 위치를 30분 동안 운영자와 허용된 안전 담당자에게 공유합니다. 상대 팀 추적에는 사용할 수 없으며 언제든 종료할 수 있습니다.": "Your current location will be shared for 30 minutes with operators and authorized safety staff. It cannot be used to track opposing teams and can be stopped at any time.",
  "동의하고 시작": "Agree and Start",
  "산행 종료까지 위치 공유가 시작되었습니다.": "Location sharing is active until the hike ends.",
  "안전 위치 공유가 시작되었습니다. 통신 상태에 따라 전달이 지연될 수 있습니다.": "safety location sharing has started. Delivery may be delayed depending on connectivity.",
  "GPS 기록은 계속됩니다. 현재 통신이 원활하지 않아 실시간 위치 공유는 지연될 수 있습니다.": "GPS recording continues. Real-time location sharing may be delayed because connectivity is currently unstable.",
  "기기 위치 공유를 종료했습니다. 오프라인이면 서버 종료 반영이 지연될 수 있습니다.": "Local sharing stopped; server updates may be delayed offline.",
  "로그인 후 SOS를 사용할 수 있습니다.": "Sign in to use SOS.",
  "긴급 상황 선택": "Select Emergency",
  "현재 위치가 안전 담당자에게 전달됩니다.": "Your current location will be sent to safety staff.",
  "SOS 전송 확인": "Confirm SOS",
  "현재 위치를 긴급 전송합니다.": "Your current location will be sent as an emergency.",
  "SOS 전송": "Send SOS",
  "SOS 위치 정보": "SOS Location Information",
  "SOS 정보가 기기에 기록되어 서버 전송을 시도했습니다. 통신 상태에 따라 실제 전달이 지연될 수 있습니다.": "SOS information was recorded on the device and a server send was attempted. Actual delivery may be delayed depending on connectivity.",
  "현재 데이터 통신이 원활하지 않습니다. 아래 좌표를 직접 확인하고 가능한 통신 수단으로 전달하세요.": "Data connectivity is currently unstable. Check the coordinates below and share them through any available communication method.",
  "GPS 오차 약": "GPS accuracy about",
  "고도": "Altitude",
  "현재 위치 좌표를 복사했습니다.": "Current location coordinates copied.",
  "좌표 복사": "Copy Coordinates",
  "확인": "OK",
  "길찾기 앱을 사용할 수 없습니다.": "Directions app is unavailable.",
  "길찾기 앱을 열지 못했습니다.": "Could not open the directions app.",
  "길찾기 실행 중 오류가 발생했습니다.": "An error occurred while launching directions.",
  "에어소프트 경기": "Airsoft Match",
  "안심귀가": "Safe Return",
  "안전산행": "Safe Hiking",
  "기존 경기장 지도, 장소 등록, 길찾기와 안전 기능을 그대로 사용합니다.": "Use the existing field map, place registration, directions, and safety features.",
  "사용자가 직접 시작한 경우에만 위치가 공유됩니다. 목적지·보호자 공유·예상 도착시간 기능을 확장할 수 있는 기본 구조입니다.": "Location is shared only when the user starts it. This provides the base for destination, guardian sharing, and ETA features.",
  "산행 시작 시 출발점과 GPS 이동 경로를 기기에서 계속 표시합니다. 인터넷이 끊겨도 GPS가 잡히면 좌표·고도·이동거리·출발점 방향을 확인할 수 있습니다.": "When hiking starts, the device keeps showing the start point and GPS route. Even without Internet, a GPS fix lets you check coordinates, altitude, distance, and direction to the start.",
  "목적지 주소 검색": "Search Destination",
  "도로명·지번·장소명": "Address or place",
  "예: 서울역, 대전시청": "Example: Seoul Station",
  "주소를 찾지 못했습니다.": "Address not found.",
  "또는 창을 닫은 뒤 지도에서 목적지를 한 번 누르세요.": "Or close this window and tap the destination on the map.",
  "검색·선택": "Search",
  "목적지가 설정되었습니다.": "Destination has been set.",
  "로그인 후 사용할 수 있습니다.": "Please sign in to use this feature.",
  "안심귀가 이동 모드가 시작되었습니다.": "Safe Return tracking has started.",
  "안전산행 모드가 시작되었습니다. GPS 경로는 데이터 통신이 없어도 계속 기록됩니다.": "Safe Hiking has started. GPS route recording continues without mobile data.",
  "안전산행 GPS 기록이 시작되었습니다. 현재 서버 통신이 원활하지 않아 공유는 지연될 수 있습니다.": "Safe Hiking GPS recording has started. Sharing may be delayed because server connectivity is unstable.",
  "위치 추적은 시작되었습니다. 내비게이션을 사용하려면 먼저 목적지를 선택해 주세요.": "Location tracking has started. Select a destination first to use navigation.",
  "내비게이션 앱을 사용할 수 없습니다.": "Navigation app is unavailable.",
  "내비게이션 앱을 열 수 없습니다.": "Unable to open the navigation app.",
  "내비게이션 실행 중 오류가 발생했습니다.": "Failed to launch navigation.",
  "화면 추적은 종료되었습니다. 서버 종료 기록은 네트워크 연결 후 다시 반영됩니다.": "On-screen tracking has stopped. The server end record will sync after network connectivity returns.",
  "안전 모드가 종료되었습니다.": "Safety tracking has stopped.",
  "먼저 현재 위치를 확인해 주세요.": "Check your current location first.",
  "오프라인 안전 정보를 복사했습니다.": "Offline safety information copied.",
  "산행 시작 후 출발점이 자동 저장됩니다.": "The start point is saved when hiking begins.",
  "산행 출발점": "Hiking start point",
  "출발점을 귀환 기준점으로 설정했습니다. 청록색으로 기록된 실제 이동 경로를 참고하세요.": "The hiking start point is now the return reference. Follow the recorded cyan breadcrumb route.",
  "계산 중...": "Calculating...",
  "귀환시간 미설정": "Return time not set",
  "목적지 미설정": "Destination not set",
  "안심귀가 기능": "Safe Return",
  "안전산행 기능": "Safe Hiking",
  "현재 위치": "Current Location",
  "목적지 선택": "Select Destination",
  "이동 중": "Moving",
  "산행 중": "Hiking",
  "이동 시작": "Start Moving",
  "산행 시작": "Start Hiking",
  "보호자 변경": "Change Guardian",
  "귀환 예정시간": "Return Time",
  "보호자 공유": "Share with Guardian",
  "공유 중": "Sharing",
  "산행 종료까지 공유": "Share Until Hike Ends",
  "경로 기록 중": "Recording Route",
  "경로 기록": "Record Route",
  "종료": "Stop",
  "장시간 정지 감지": "Long Stop Detection",
  "경로 이탈 알림": "Route Deviation Alert",
  "지도 저장됨": "Map saved",
  "산행 전 저장 필요": "Save before hiking",
  "지도 저장 중...": "Saving map...",
  "오프라인 지도 저장": "Save Offline Map",
  "산행 전 오프라인 지도 준비": "Prepare Offline Map Before Hiking",
  "Chrome에서는 위치와 화면을 확인할 수 있습니다. 실제 오프라인 지도 저장은 휴대폰 앱에서 실행하세요.": "Chrome can be used to check the screen and location. Save the actual offline map in the mobile app.",
  "인터넷이 연결된 곳에서 필요한 산행 구간을 지도에 보이게 한 뒤 아래 버튼을 누르세요. 현재 보이는 범위가 휴대폰에 저장됩니다.": "While online, frame the hiking area you need on the map, then tap the button below. The visible area is saved on your phone.",
  "저장 완료: 인터넷이 끊기면 저장 지도 위에 현재 GPS, 청록색 이동경로, 출발점이 계속 표시됩니다.": "Saved: if Internet disconnects, current GPS, the cyan route, and the start point continue to appear over the saved map.",
  "산행 안전 계획": "Hiking Safety Plan",
  "위치 공유 중": "Sharing active",
  "공유 대기": "Share ready",
  "귀환 예정": "Planned Return",
  "공유 방식": "Sharing Mode",
  "산행 종료까지": "Until hike ends",
  "사용자 시작 대기": "Waiting to start",
  "산행 종료 시 ‘안전하게 하산했습니다’를 누르면 위치 공유와 GPS 추적이 함께 종료되고 안전 하산 상태가 기록됩니다.": "At the end of the hike, tap “I Arrived Safely” to stop location sharing and GPS tracking together and record a safe completion.",
  "오프라인 안전 정보": "Offline Safety",
  "GPS 사용": "GPS READY",
  "현재 좌표": "Coordinates",
  "GPS 오차": "GPS Accuracy",
  "기록 거리": "Recorded",
  "출발점 방향": "Start Point",
  "경과 시간": "Elapsed",
  "저장 지도": "Saved Map",
  "출발점 귀환": "Return to Start",
  "안전정보 복사": "Copy Safety Info",
  "현재 지도 저장": "Save Visible Map",
  "저장 지도 삭제": "Delete Saved Map",
  "산행 전에 지도를 원하는 범위로 이동·확대/축소한 뒤 ‘현재 지도 저장’을 누르세요. 저장된 지도는 앱 기기에 남아 인터넷이 끊겨도 배경으로 표시되고, 그 위에 현재 GPS·청록색 이동경로·출발점이 계속 갱신됩니다. 주소검색·원격 공유·SOS 서버 전달은 통신 복구 전까지 지연될 수 있습니다.": "Before hiking, pan and zoom to the area you need and tap “Save Visible Map”. The saved map remains on the device and is shown offline while current GPS, the cyan breadcrumb, and the start point keep updating above it. Address search, remote sharing, and SOS server delivery may wait for connectivity to return.",
  "사용설명서": "GUIDE",
  "위치 확인 중": "Locating...",
  "내 위치": "My Location",
  "등록 중": "Registering...",
  "장소 등록": "Register Place",
  "목적지 등록": "Set Destination",
  "목적지 변경": "Change Destination",
  "공유 종료": "Stop Sharing",
  "30분 위치 공유": "Share Location 30 min",
  "긴급 SOS": "Emergency SOS",
  "사용법: ‘내 위치’로 GPS 위치를 확인하고, ‘장소 등록’으로 경기장을 신청합니다. ‘30분 위치 공유’와 ‘긴급 SOS’는 기존 방식 그대로 작동합니다.": "How to use: check your GPS with My Location and request a field with Register Place. 30-minute sharing and Emergency SOS work as before.",
  "안전산행은 보호자와 귀환 예정시간을 설정한 뒤 ‘산행 시작’을 누를 수 있습니다. 위치 공유는 산행 종료까지 유지되며, 데이터 통신이 끊겨도 기기 GPS 경로 기록은 계속됩니다. 하산 후에는 ‘안전하게 하산했습니다’를 눌러 종료하세요.": "In Safe Hiking, set a guardian and planned return time, then start the hike. Location sharing can stay active until the hike ends, while device GPS route recording continues even if data disconnects. Tap “I Arrived Safely” after descending.",
  "지도에서 원하는 지점을 누르거나 ‘목적지 등록’을 눌러 목적지를 지정할 수 있습니다. 위치 기능은 사용자가 직접 시작해야만 작동하며, 긴급 시에는 ‘긴급 SOS’를 사용하세요.": "Tap a point on the map or Set Destination. Location features run only when you start them; use Emergency SOS when needed.",
  "선택한 지점이 목적지로 등록되었습니다.": "The selected point was set as the destination.",
  "경기장 정보를 불러오지 못했습니다:": "Could not load field information:",
  "등록된 경기장이 없습니다. “경기장 등록”으로 첫 장소를 추가하세요.": "No registered fields yet. Add the first place with Field Registration.",
  "청록색 = 실제 GPS 이동경로": "Cyan = recorded GPS breadcrumb",
  "저장 지도 + 청록색 GPS 이동경로": "Saved map + cyan GPS breadcrumb",
  "주소 정보 없음": "No address information",
  "이 경기장으로 길찾기": "Directions to this Field"
};
