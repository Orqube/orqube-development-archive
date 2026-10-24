import '../../../utils/orqube_i18n.dart';

/// 6-language strings used by the token creation progress flow.
/// Stage codes (WALLET/CREATE/...) intentionally stay in English so the
/// production pipeline remains identical in every language.
class TokenCreationI18n {
  static String get language =>
      OrqubeI18n.normalize(OrqubeI18n.currentLanguage);

  static String t(String key) {
    final row = _strings[key];
    return row?[language] ?? row?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    'progressTitle': {
      'ko': 'TOKEN PRODUCTION PROGRESS',
      'en': 'TOKEN PRODUCTION PROGRESS',
      'ja': 'TOKEN PRODUCTION PROGRESS',
      'zh': 'TOKEN PRODUCTION PROGRESS',
      'fr': 'TOKEN PRODUCTION PROGRESS',
      'pt': 'TOKEN PRODUCTION PROGRESS',
    },
    'progressSubtitle': {
      'ko': '단계를 누르면 자세한 도움말을 볼 수 있습니다.',
      'en': 'Tap a step to open detailed guidance.',
      'ja': '各ステップをタップすると詳しいヘルプを表示します。',
      'zh': '点击步骤可查看详细帮助。',
      'fr': 'Touchez une étape pour afficher l’aide détaillée.',
      'pt': 'Toque em uma etapa para ver a ajuda detalhada.',
    },
    'completed': {
      'ko': '완료', 'en': 'Completed', 'ja': '完了', 'zh': '已完成', 'fr': 'Terminé', 'pt': 'Concluído',
    },
    'current': {
      'ko': '현재', 'en': 'Current', 'ja': '現在', 'zh': '当前', 'fr': 'En cours', 'pt': 'Atual',
    },
    'locked': {
      'ko': '잠금', 'en': 'Locked', 'ja': 'ロック', 'zh': '锁定', 'fr': 'Verrouillé', 'pt': 'Bloqueado',
    },
    'goToStep': {
      'ko': '이 단계로 이동',
      'en': 'Go to this step',
      'ja': 'このステップへ移動',
      'zh': '前往此步骤',
      'fr': 'Aller à cette étape',
      'pt': 'Ir para esta etapa',
    },
    'testnetPayNote': {
      'ko': 'Testnet 배포에서는 PAY/VERIFY 유료 단계가 잠금 상태로 유지됩니다. Kaia Mainnet 배포 후 활성화됩니다.',
      'en': 'PAY/VERIFY remain locked on Testnet. They become available after a Kaia Mainnet deployment.',
      'ja': 'Testnet では PAY/VERIFY の有料ステップはロックされます。Kaia Mainnet 配布後に有効になります。',
      'zh': 'Testnet 上 PAY/VERIFY 付费步骤保持锁定，Kaia Mainnet 部署后启用。',
      'fr': 'PAY/VERIFY restent verrouillés sur Testnet et s’activent après un déploiement Kaia Mainnet.',
      'pt': 'PAY/VERIFY ficam bloqueados na Testnet e são ativados após o deploy na Kaia Mainnet.',
    },
    'help_wallet': {
      'ko': '배포와 결제에 사용할 지갑을 연결합니다. EVM 체인은 현재 브라우저 지갑 계정을 다시 확인해 프로젝트 지갑과 일치시키며, 개인키는 ORQUBE로 전송하지 않습니다.',
      'en': 'Connect the wallet used for deployment and payment. For EVM chains, ORQUBE re-checks the active browser-wallet account and matches it to the project wallet. Private keys are never sent to ORQUBE.',
      'ja': '配布と支払いに使うウォレットを接続します。EVM チェーンでは現在のブラウザウォレット口座を再確認し、プロジェクトのウォレットと一致させます。秘密鍵は ORQUBE に送信されません。',
      'zh': '连接用于部署和支付的钱包。EVM 链会重新确认当前浏览器钱包账户并与项目钱包匹配，私钥不会发送到 ORQUBE。',
      'fr': 'Connectez le portefeuille utilisé pour le déploiement et le paiement. Pour les chaînes EVM, ORQUBE vérifie à nouveau le compte actif du portefeuille du navigateur. Les clés privées ne sont jamais envoyées à ORQUBE.',
      'pt': 'Conecte a carteira usada para deploy e pagamento. Em redes EVM, o ORQUBE confirma novamente a conta ativa da carteira do navegador. As chaves privadas nunca são enviadas ao ORQUBE.',
    },
    'help_create': {
      'ko': '토큰 이름, 심볼, 설명, 체인과 Total Supply를 사용자가 직접 입력해 프로젝트를 만듭니다. Total Supply에는 고정값이나 자동 기본값을 사용하지 않습니다.',
      'en': 'Create the project by entering the token name, symbol, description, chain and Total Supply yourself. Total Supply never uses a fixed or automatic default value.',
      'ja': 'トークン名、シンボル、説明、チェーン、Total Supply をユーザーが直接入力してプロジェクトを作成します。Total Supply に固定値や自動初期値は使用しません。',
      'zh': '由用户手动输入代币名称、符号、说明、链和 Total Supply 来创建项目。Total Supply 不使用固定值或自动默认值。',
      'fr': 'Créez le projet en saisissant vous-même le nom, le symbole, la description, la chaîne et le Total Supply. Aucun montant fixe ou automatique n’est utilisé.',
      'pt': 'Crie o projeto informando manualmente nome, símbolo, descrição, rede e Total Supply. O Total Supply não usa valor fixo nem padrão automático.',
    },
    'help_test': {
      'ko': '실제 배포 전에 선택한 테스트넷과 현재 지갑 계정을 확인합니다. Kaia는 Kairos, Polygon은 Amoy에서 먼저 확인하도록 구성되어 있습니다.',
      'en': 'Before deployment, confirm the selected testnet and the active wallet account. Kaia uses Kairos and Polygon uses Amoy for the test stage.',
      'ja': '実際の配布前に、選択したテストネットと現在のウォレット口座を確認します。Kaia は Kairos、Polygon は Amoy で先に確認します。',
      'zh': '正式部署前确认所选测试网和当前钱包账户。Kaia 使用 Kairos，Polygon 使用 Amoy 进行测试。',
      'fr': 'Avant le déploiement, confirmez le testnet sélectionné et le compte actif du portefeuille. Kaia utilise Kairos et Polygon utilise Amoy.',
      'pt': 'Antes do deploy, confirme a testnet selecionada e a conta ativa da carteira. Kaia usa Kairos e Polygon usa Amoy.',
    },
    'help_deploy': {
      'ko': '토큰을 온체인에 배포합니다. DEPLOY 직전에 사용자가 직접 입력한 최종 Total Supply를 다시 확인하고 승인한 뒤 지갑 서명을 진행합니다.',
      'en': 'Deploy the token on-chain. Immediately before DEPLOY, re-check and approve the final Total Supply entered by the user, then approve the wallet transaction.',
      'ja': 'トークンをオンチェーンに配布します。DEPLOY 直前にユーザーが入力した最終 Total Supply を再確認・承認してからウォレット署名を行います。',
      'zh': '将代币部署到链上。DEPLOY 前会再次确认并批准用户手动输入的最终 Total Supply，然后进行钱包签名。',
      'fr': 'Déployez le jeton on-chain. Juste avant DEPLOY, vérifiez et approuvez de nouveau le Total Supply saisi manuellement, puis signez avec le portefeuille.',
      'pt': 'Faça o deploy do token on-chain. Antes do DEPLOY, confirme novamente o Total Supply informado manualmente e depois aprove a transação na carteira.',
    },
    'help_pay': {
      'ko': 'Kaia Mainnet의 ORQUBE AUTO VERIFY 서비스 이용료를 KAI 또는 ORBS 중 하나로 결제합니다. Testnet에서는 이 단계가 비활성화됩니다.',
      'en': 'Pay the ORQUBE AUTO VERIFY service fee on Kaia Mainnet using either KAI or ORBS. This step is disabled on Testnet.',
      'ja': 'Kaia Mainnet の ORQUBE AUTO VERIFY 利用料を KAI または ORBS のどちらかで支払います。Testnet では無効です。',
      'zh': '在 Kaia Mainnet 上使用 KAI 或 ORBS 支付 ORQUBE AUTO VERIFY 服务费。Testnet 上此步骤停用。',
      'fr': 'Payez les frais du service ORQUBE AUTO VERIFY sur Kaia Mainnet en KAI ou ORBS. Cette étape est désactivée sur Testnet.',
      'pt': 'Pague a taxa do ORQUBE AUTO VERIFY na Kaia Mainnet com KAI ou ORBS. Esta etapa fica desativada na Testnet.',
    },
    'help_verify': {
      'ko': 'Deployment Archive에 저장된 소스·컴파일러·옵티마이저·생성 인자 등을 이용해 Source Verification을 진행합니다. 결제 성공 후 재검증은 재결제 없이 다시 시도할 수 있습니다.',
      'en': 'Run Source Verification using the source, compiler, optimizer, constructor arguments and other data stored in the Deployment Archive. After payment succeeds, verification can be retried without paying again.',
      'ja': 'Deployment Archive に保存されたソース、コンパイラ、最適化設定、コンストラクタ引数などを使って Source Verification を行います。支払い成功後の再検証では再決済しません。',
      'zh': '使用 Deployment Archive 中保存的源码、编译器、优化器、构造参数等执行 Source Verification。支付成功后可无需再次付款重新验证。',
      'fr': 'Effectuez la vérification du code source avec les données du Deployment Archive : source, compilateur, optimiseur, arguments du constructeur, etc. Après paiement, une nouvelle tentative ne nécessite pas de nouveau paiement.',
      'pt': 'Execute a verificação do código-fonte usando os dados do Deployment Archive: fonte, compilador, otimizador, argumentos do construtor etc. Após o pagamento, novas tentativas não exigem novo pagamento.',
    },
    'help_use': {
      'ko': 'TOKEN USE CENTER에서 REWARD, MEMBERSHIP, CAMPAIGN, LIQUIDITY READY와 이후 DROPS·LIQUIDITY·SWAP 활용을 설정합니다. 최소 한 개의 실제 사용 항목을 구성하면 진행상태에 반영됩니다.',
      'en': 'Configure real token utility in TOKEN USE CENTER: REWARD, MEMBERSHIP, CAMPAIGN, LIQUIDITY READY and later DROPS, LIQUIDITY and SWAP. The progress updates after at least one utility item is configured.',
      'ja': 'TOKEN USE CENTER で REWARD、MEMBERSHIP、CAMPAIGN、LIQUIDITY READY、その後の DROPS・LIQUIDITY・SWAP を設定します。少なくとも1つの利用項目を設定すると進捗に反映されます。',
      'zh': '在 TOKEN USE CENTER 中配置 REWARD、MEMBERSHIP、CAMPAIGN、LIQUIDITY READY 以及后续 DROPS、LIQUIDITY、SWAP。至少配置一个实际用途后进度会更新。',
      'fr': 'Configurez les usages réels dans TOKEN USE CENTER : REWARD, MEMBERSHIP, CAMPAIGN, LIQUIDITY READY puis DROPS, LIQUIDITY et SWAP. Le progrès est mis à jour dès qu’au moins un usage est configuré.',
      'pt': 'Configure usos reais no TOKEN USE CENTER: REWARD, MEMBERSHIP, CAMPAIGN, LIQUIDITY READY e depois DROPS, LIQUIDITY e SWAP. O progresso é atualizado quando pelo menos um uso é configurado.',
    },
    'help_aiMarketing': {
      'ko': 'AI가 TOKEN_FIT_SCORE, 국가, 언어, 플랫폼과 홍보문을 생성해 Human Approval Queue로 보냅니다. 외부 자동게시와 유료광고는 기존 정책대로 OFF 상태를 유지합니다.',
      'en': 'AI generates TOKEN_FIT_SCORE, target country, language, platform and promotional copy, then sends it to the Human Approval Queue. External auto-posting and paid ads remain OFF.',
      'ja': 'AI が TOKEN_FIT_SCORE、対象国、言語、プラットフォーム、販促文を生成し Human Approval Queue に送ります。外部自動投稿と有料広告は OFF のままです。',
      'zh': 'AI 生成 TOKEN_FIT_SCORE、目标国家、语言、平台和推广文案，并发送到 Human Approval Queue。外部自动发布和付费广告继续保持关闭。',
      'fr': 'L’IA génère le TOKEN_FIT_SCORE, le pays cible, la langue, la plateforme et le texte promotionnel, puis l’envoie dans la Human Approval Queue. La publication automatique externe et les publicités payantes restent désactivées.',
      'pt': 'A IA gera TOKEN_FIT_SCORE, país, idioma, plataforma e texto promocional e envia para a Human Approval Queue. Postagem automática externa e anúncios pagos continuam desligados.',
    },
    'supplyLabel': {
      'ko': 'Total Supply · 총 발행량',
      'en': 'Total Supply',
      'ja': 'Total Supply · 総発行量',
      'zh': 'Total Supply · 总发行量',
      'fr': 'Total Supply · Offre totale',
      'pt': 'Total Supply · Oferta total',
    },
    'supplyHint': {
      'ko': '예: 1000000', 'en': 'Example: 1000000', 'ja': '例: 1000000', 'zh': '例如：1000000', 'fr': 'Exemple : 1000000', 'pt': 'Exemplo: 1000000',
    },
    'supplyHelper': {
      'ko': '고정값/자동값 없이 사용자가 직접 입력합니다. DEPLOY 직전에 최종 수량을 다시 확인합니다.',
      'en': 'Enter it manually. No fixed or automatic value is used. The final amount is checked again immediately before DEPLOY.',
      'ja': '固定値・自動値を使わず、ユーザーが直接入力します。DEPLOY 直前に最終数量を再確認します。',
      'zh': '不使用固定值或自动值，由用户手动输入。DEPLOY 前会再次确认最终数量。',
      'fr': 'Saisissez la valeur manuellement, sans valeur fixe ni automatique. Le montant final est revérifié juste avant DEPLOY.',
      'pt': 'Informe manualmente, sem valor fixo ou automático. O valor final será confirmado novamente antes do DEPLOY.',
    },
    'tokenFeaturesTitle': {
      'ko': '토큰 기능 선택', 'en': 'Token Features', 'ja': 'トークン機能選択', 'zh': '代币功能选择', 'fr': 'Fonctions du jeton', 'pt': 'Recursos do token',
    },
    'tokenFeaturesHelp': {
      'ko': '발행량과 함께 토큰의 핵심 기능을 선택합니다. Kaia/Polygon EVM 배포 시 실제 컨트랙트 코드에 적용됩니다.',
      'en': 'Choose the token features together with supply. For Kaia/Polygon EVM deployment, these choices are applied to the actual contract code.',
      'ja': '発行量と一緒にトークン機能を選択します。Kaia/Polygon EVM 配布では実際のコントラクトに反映されます。',
      'zh': '与发行量一起选择代币功能。Kaia/Polygon EVM 部署时会实际写入合约代码。',
      'fr': 'Choisissez les fonctions avec l’offre. Sur Kaia/Polygon EVM, elles sont intégrées au contrat réel.',
      'pt': 'Escolha os recursos junto com a oferta. Em Kaia/Polygon EVM, eles são aplicados ao contrato real.',
    },
    'issuanceMode': {'ko':'발행 방식','en':'Issuance Mode','ja':'発行方式','zh':'发行方式','fr':'Mode d’émission','pt':'Modo de emissão'},
    'fixedSupply': {'ko':'고정 발행량','en':'Fixed Supply','ja':'固定発行量','zh':'固定发行量','fr':'Offre fixe','pt':'Oferta fixa'},
    'fixedSupplyHelp': {'ko':'최초 발행 후 추가 발행할 수 없습니다.','en':'No additional tokens can be minted after deployment.','ja':'配布後に追加発行できません。','zh':'部署后不能追加发行。','fr':'Aucune émission supplémentaire après le déploiement.','pt':'Não permite emissão adicional após o deploy.'},
    'mintable': {'ko':'추가 발행 가능','en':'Mintable','ja':'追加発行可能','zh':'可追加发行','fr':'Émission supplémentaire','pt':'Emissão adicional'},
    'mintableHelp': {'ko':'관리자 지갑이 최대 발행량 범위 안에서 추가 발행할 수 있습니다.','en':'The admin wallet can mint more tokens up to the maximum supply.','ja':'管理者ウォレットが最大発行量まで追加発行できます。','zh':'管理员钱包可在最大发行量范围内追加发行。','fr':'Le portefeuille administrateur peut émettre jusqu’à l’offre maximale.','pt':'A carteira administradora pode emitir até a oferta máxima.'},
    'capSupply': {'ko':'최대 발행량 · Cap','en':'Maximum Supply · Cap','ja':'最大発行量 · Cap','zh':'最大发行量 · Cap','fr':'Offre maximale · Cap','pt':'Oferta máxima · Cap'},
    'capRequired': {'ko':'추가 발행을 선택하면 최대 발행량을 입력해야 합니다.','en':'Enter the maximum supply when Mintable is selected.','ja':'追加発行を選択した場合は最大発行量を入力してください。','zh':'选择追加发行时请输入最大发行量。','fr':'Saisissez l’offre maximale lorsque l’émission supplémentaire est activée.','pt':'Informe a oferta máxima ao ativar emissão adicional.'},
    'capTooSmall': {'ko':'최대 발행량은 최초 발행량보다 작을 수 없습니다.','en':'Maximum supply cannot be lower than the initial supply.','ja':'最大発行量は初期発行量より少なくできません。','zh':'最大发行量不能小于初始发行量。','fr':'L’offre maximale ne peut pas être inférieure à l’offre initiale.','pt':'A oferta máxima não pode ser menor que a oferta inicial.'},
    'burnable': {'ko':'소각 가능 · Burnable','en':'Burnable','ja':'バーン可能 · Burnable','zh':'可销毁 · Burnable','fr':'Destruction · Burnable','pt':'Queimável · Burnable'},
    'burnableHelp': {'ko':'보유자가 자신의 토큰을 영구 소각할 수 있습니다.','en':'Holders can permanently burn their own tokens.','ja':'保有者が自分のトークンを永久にバーンできます。','zh':'持有人可永久销毁自己的代币。','fr':'Les détenteurs peuvent détruire définitivement leurs propres jetons.','pt':'Os titulares podem queimar permanentemente seus próprios tokens.'},
    'pausable': {'ko':'긴급 정지 · Pausable','en':'Emergency Pause · Pausable','ja':'緊急停止 · Pausable','zh':'紧急暂停 · Pausable','fr':'Pause d’urgence · Pausable','pt':'Pausa de emergência · Pausable'},
    'pausableHelp': {'ko':'관리자가 사고 대응 시 토큰 전송을 일시 중지하고 다시 재개할 수 있습니다.','en':'The admin can temporarily pause and resume token transfers during an incident.','ja':'管理者が緊急時に送金を一時停止・再開できます。','zh':'管理员可在事故处理期间暂停并恢复代币转账。','fr':'L’administrateur peut suspendre puis reprendre les transferts en cas d’incident.','pt':'O administrador pode pausar e retomar transferências durante um incidente.'},
    'adminAuto': {'ko':'관리자 권한은 Mint/Pause 선택 시 배포 지갑에 자동 부여됩니다.','en':'Admin authority is assigned automatically to the deployment wallet when Mint/Pause is enabled.','ja':'Mint/Pause を選択すると管理者権限は配布ウォレットに自動付与されます。','zh':'启用 Mint/Pause 时，管理员权限会自动授予部署钱包。','fr':'L’autorité admin est attribuée automatiquement au portefeuille de déploiement si Mint/Pause est activé.','pt':'A autoridade de administrador é atribuída automaticamente à carteira de deploy quando Mint/Pause é ativado.'},
    'evmFeatureNote': {'ko':'※ 이번 기능은 Kaia / Polygon(EVM) 컨트랙트에 실제 적용됩니다. Solana는 권한 구조가 달라 별도 방식으로 처리됩니다.','en':'※ These features are applied to Kaia / Polygon (EVM) contracts. Solana uses a different authority model and is handled separately.','ja':'※ この機能は Kaia / Polygon(EVM) コントラクトに適用されます。Solana は権限構造が異なるため別方式です。','zh':'※ 这些功能实际应用于 Kaia / Polygon(EVM) 合约。Solana 权限结构不同，将单独处理。','fr':'※ Ces fonctions s’appliquent aux contrats Kaia / Polygon (EVM). Solana utilise un modèle d’autorité différent.','pt':'※ Estes recursos são aplicados a contratos Kaia / Polygon (EVM). Solana usa um modelo de autoridade diferente.'},
    'supplyRequired': {
      'ko': '총 발행량을 숫자로 직접 입력하세요.',
      'en': 'Enter the Total Supply manually as a number.',
      'ja': 'Total Supply を数値で直接入力してください。',
      'zh': '请手动输入数字形式的 Total Supply。',
      'fr': 'Saisissez manuellement le Total Supply sous forme numérique.',
      'pt': 'Digite manualmente o Total Supply como número.',
    },
    'supplyRange': {
      'ko': '1 ~ 1,000,000,000,000 범위로 입력하세요.',
      'en': 'Enter a value from 1 to 1,000,000,000,000.',
      'ja': '1 ～ 1,000,000,000,000 の範囲で入力してください。',
      'zh': '请输入 1 到 1,000,000,000,000 之间的数值。',
      'fr': 'Saisissez une valeur comprise entre 1 et 1 000 000 000 000.',
      'pt': 'Digite um valor entre 1 e 1.000.000.000.000.',
    },
    'finalSupplyTitle': {
      'ko': 'DEPLOY 전 최종 발행량 확인',
      'en': 'Final supply check before DEPLOY',
      'ja': 'DEPLOY 前の最終発行量確認',
      'zh': 'DEPLOY 前最终发行量确认',
      'fr': 'Vérification finale de l’offre avant DEPLOY',
      'pt': 'Confirmação final da oferta antes do DEPLOY',
    },
    'finalSupplyBody': {
      'ko': '아래 값이 실제 컨트랙트에 적용될 최종 Total Supply입니다. 필요하면 지금 직접 수정하세요.',
      'en': 'This is the final Total Supply that will be applied to the contract. Edit it manually now if needed.',
      'ja': '以下の値が実際のコントラクトに適用される最終 Total Supply です。必要なら今ここで直接修正してください。',
      'zh': '以下数值将作为实际合约的最终 Total Supply。如有需要，请现在手动修改。',
      'fr': 'Cette valeur sera le Total Supply final appliqué au contrat. Modifiez-la manuellement maintenant si nécessaire.',
      'pt': 'Este será o Total Supply final aplicado ao contrato. Altere manualmente agora, se necessário.',
    },
    'finalSupplyWarning': {
      'ko': '배포 후에는 총 발행량 변경이 어렵습니다. 숫자를 다시 확인한 뒤 승인하세요.',
      'en': 'Changing Total Supply after deployment is difficult. Check the number again before approving.',
      'ja': '配布後の Total Supply 変更は困難です。数値を再確認して承認してください。',
      'zh': '部署后很难更改 Total Supply。请再次确认数值后批准。',
      'fr': 'Modifier le Total Supply après le déploiement est difficile. Vérifiez encore une fois le nombre avant d’approuver.',
      'pt': 'Alterar o Total Supply após o deploy é difícil. Confira o número novamente antes de aprovar.',
    },
    'cancel': {
      'ko': '취소', 'en': 'Cancel', 'ja': 'キャンセル', 'zh': '取消', 'fr': 'Annuler', 'pt': 'Cancelar',
    },
    'confirmSupply': {
      'ko': '발행량 확인 · 계속',
      'en': 'Confirm supply · Continue',
      'ja': '発行量を確認 · 続行',
      'zh': '确认发行量 · 继续',
      'fr': 'Confirmer l’offre · Continuer',
      'pt': 'Confirmar oferta · Continuar',
    },
  };
}
