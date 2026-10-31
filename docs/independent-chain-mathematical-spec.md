# ORQUBE 독립체인 — 수학적 상태 전이와 검증 규칙

작성: ORQUBE Foundation · 2026-10-31  
대상: 독립 PoW 실험 노드 v0.5  
[노드 구성·3노드 시험 기록](https://github.com/Orqube/orqube-development-archive/issues/2)

이 문서는 확보된 v0.5 코드의 연산을 수학적으로 표현합니다. 새로운 암호 알고리즘이나 보안 증명을 제안하는 문서가 아닙니다. 발행량·배분 조건 등 비공개 정책 수치는 제외합니다. 현재 구현과 미래 구상은 구분합니다.

## 1. 기호와 상태

| 기호 | 뜻 |
|---|---|
| $B_h$ | 높이 $h$의 블록 |
| $C_h=(B_0,\ldots,B_h)$ | 제네시스부터 연결된 체인 |
| $U_h$ | 높이 $h$ 처리 후 미사용 출력(UTXO) 집합 |
| $S_h$ | 높이 $h$까지의 누적 신규 발행량 |
| $H(x)$ | $\mathrm{SHA256}(\mathrm{SHA256}(x))$ |
| $E(x)$ | 코드의 정규화 JSON 바이트 직렬화 |
| $R(x)$ | 바이트 순서 반전 |
| $b_h$ | 헤더의 압축 목표값 bits |
| $T(b_h)$ | bits를 풀어 얻는 작업증명 목표값 |
| $\Phi$ | 검증을 통과한 블록을 적용하는 상태 전이 |

$$
(U_h,S_h)=\Phi(U_{h-1},S_{h-1},B_h)
$$

검증 실패 시 $\Phi$는 정의되지 않으며 해당 블록은 채택하지 않습니다. 이 식은 결과의 수학적 표현이며, 코드의 실행 순서와 저장 절차는 아래에서 따로 설명합니다.

## 2. 블록 헤더와 해시

헤더는 다음 여섯 항목의 바이트 연결입니다.

$$
\mathrm{hdr}(B_h)=
\mathrm{LE}_{32}(v_h)
\Vert R(\mathrm{hexDecode}(p_h))
\Vert R(\mathrm{hexDecode}(m_h))
\Vert \mathrm{LE}_{32}(t_h)
\Vert \mathrm{LE}_{32}(b_h)
\Vert \mathrm{LE}_{32}(n_h)
$$

$$
|\mathrm{hdr}(B_h)|=4+32+32+4+4+4=80\ \mathrm{bytes}
$$

$v_h$: 버전, $p_h$: 이전 블록 해시, $m_h$: 머클 루트, $t_h$: 시각, $n_h$: 논스. 정수 필드는 boolean을 제외한 32비트 부호 없는 정수입니다.

표시용 블록 해시는 다음과 같습니다.

$$
\mathrm{id}(B_h)=\mathrm{hex}\!\left(R(H(\mathrm{hdr}(B_h)))\right)
$$

연결 조건:

$$
p_h=\mathrm{id}(B_{h-1}),\qquad h=h_{\mathrm{prev}}+1
$$

해시 표시 순서와 정수 해석을 임의로 바꾸면 코드와 다른 결과가 나오므로 위 직렬화 규칙을 함께 적용해야 합니다.

## 3. 작업증명과 논스 탐색

bits의 지수와 가수를 다음과 같이 해석합니다.

$$
e=b\gg24,\qquad c=b\mathbin{\&}\mathtt{0x007fffff}
$$

$$
T(b)=
\begin{cases}
c\gg 8(3-e),&e\le3\\
c\ll 8(e-3),&e>3
\end{cases}
$$

음수 부호 비트, 0 가수 및 $T\notin(0,2^{256})$는 거부합니다. 현재 노드는 정해진 고정 시험 bits와 다른 값을 거부합니다.

$$
y_h=\mathrm{int}_{16}(\mathrm{id}(B_h))
$$

$$
\boxed{y_h\le T(b_h)}
$$

코드의 성공 조건은 엄밀하게 **이하**입니다. 균일하고 독립적인 해시 결과를 가정하면:

$$
P(\mathrm{success})=\frac{T+1}{2^{256}},\qquad
\mathbb{E}[N]=\frac{2^{256}}{T+1}
$$

논스는 $0\le n\le2^{32}-1$ 범위에서 탐색합니다. 이는 평균 연산량에 관한 모델이며 일정 시간 내 블록 생성을 보장하지 않습니다.

## 4. 거래·서명에 대한 머클 커밋

보상 설명에는 네트워크, 높이, 수령 공개키와 보상값이 들어갑니다.

$$
q_0=\mathrm{hex}(H(E(\mathrm{coinbaseDescription}_h)))
$$

서명이 포함된 거래 전체의 해시를 나머지 잎으로 둡니다.

$$
q_j=\mathrm{hex}(H(E(tx_j))),\qquad j=1,\ldots,k
$$

잎을 내부 바이트 순서로 바꾼 뒤 인접한 두 노드를 묶습니다.

$$
L_j^{(0)}=R(\mathrm{hexDecode}(q_j))
$$

$$
L_j^{(r+1)}=H\!\left(L_{2j}^{(r)}\Vert L_{2j+1}^{(r)}\right)
$$

한 단계의 노드 수가 홀수이면 마지막 항을 복제합니다. 최종 루트를 다시 반전해 16진수로 표시합니다.

$$
m_h=\mathrm{hex}(R(L_0^{(\mathrm{last})}))
$$

검증 노드는 본문으로 재계산한 루트와 헤더의 루트가 일치하는지 확인합니다. 거래 참조용 ID에서는 서명을 제외하지만, 블록의 머클 커밋에는 서명 전체가 포함됩니다.

## 5. 거래 소유권과 서명 검증

거래 본문은 다음 세 항목입니다.

$$
M_{tx}=E(\{\mathrm{network},\mathrm{inputs},\mathrm{outputs}\})
$$

입력 $i$가 참조하는 UTXO 소유자의 공개키를 $Q_i$라 할 때:

$$
\mathrm{Verify}_{Q_i}^{\mathrm{ECDSA/SHA256}}
(M_{tx},\sigma_i)=\mathrm{true}
$$

현재 곡선은 secp256k1입니다. 공개키는 코드가 요구하는 압축 형식과 유효 곡선점 검사를 통과해야 합니다.

거래 참조용 ID:

$$
\mathrm{txid}=\mathrm{hex}(H(M_{tx}))
$$

서명 수는 입력 수와 같아야 하며, 거래의 네트워크 식별자가 현재 실험 네트워크와 일치해야 합니다. 이 서명 구현은 양자내성 서명이 아닙니다.

## 6. UTXO와 수량 보존

입력 참조 집합을 $I$, 출력 목록을 $O$라 합니다.

$$
I\subseteq\mathrm{dom}(U),\qquad |I|=\text{입력 목록 길이}
$$

첫 번째 조건은 이미 사용되었거나 존재하지 않는 출력을 거부하고, 두 번째는 중복 입력을 거부합니다.

$$
V_{\mathrm{in}}=\sum_{i\in I}U[i].\mathrm{amount}
$$

$$
V_{\mathrm{out}}=\sum_{o\in O}o.\mathrm{amount}
$$

$$
V_{\mathrm{out}}\le V_{\mathrm{in}},\qquad
f_{tx}=V_{\mathrm{in}}-V_{\mathrm{out}}\ge0
$$

각 출력은 허용 범위 안의 양의 정수입니다. 부동소수점 수량이나 boolean을 수량으로 인정하지 않습니다.

$$
U'=(U\setminus I)\cup
\{(\mathrm{txid}:j)\mapsto O_j\}
$$

시험 보상 출력에는 성숙 조건도 적용합니다.

$$
h-h_{\mathrm{created}}\ge M_{\mathrm{lab}},
\qquad M_{\mathrm{lab}}=2
$$

이 값은 로컬 시험용입니다. 거래 거부 시 호출자의 UTXO 상태를 변경하지 않는 구조로 구현되어 있습니다.

## 7. 블록 보상과 누적량의 관계

발행 정책의 비공개 수치는 기호로 둡니다. 코드의 정수 감소 규칙은 다음과 같이 표현할 수 있습니다.

$$
s(h,S)=
\min\!\left(
\left\lfloor\frac{A}{2^{\lfloor(h-1)/J\rfloor}}\right\rfloor,
C_{\max}-S
\right)
$$

$A$: 초기 단위 보상, $J$: 감소 구간, $C_{\max}$: 설계 상한. 이 기호는 기존 실험 코드의 함수를 추상화한 것이며 새 정책 결정이 아닙니다.

$$
F_h=\sum_{tx\in B_h}f_{tx}
$$

$$
r_h=s(h,S_{h-1})+F_h
$$

$$
S_h=S_{h-1}+s(h,S_{h-1})
$$

수수료는 기존 수량의 이동이므로 신규 발행 누적량에 다시 더하지 않습니다. 정수 내림 때문에 누적량이 상한에 정확히 도달한다는 보장은 없습니다. 메인넷 발행 일정은 이 문서에서 확정하지 않습니다.

## 8. 블록 시각 검증

직전 최대 11개 블록 시각을 정렬한 집합을 $A_h$라 합니다. 현재 코드의 중앙값은 짝수 개일 때 위쪽 중앙 원소를 택합니다.

$$
\mathrm{MTP}_h=\mathrm{sort}(A_h)_{\lfloor |A_h|/2\rfloor}
$$

$$
t_h>\mathrm{MTP}_h,\qquad
t_h\le t_{\mathrm{local}}+7200
$$

미래 시각 거부는 검증 노드의 현재 시각에 의존합니다. 현재 시점에 거부한 블록이 시간이 지난 뒤 허용될 수 있으며, 시간 동기화 공격에 대한 전체 방어를 구현했다는 뜻은 아닙니다.

## 9. 누적 작업량과 체인 선택

블록별 기대 작업량 지표:

$$
w(B_h)=\left\lfloor\frac{2^{256}}{T(b_h)+1}\right\rfloor
$$

제네시스를 제외한 체인의 누적 지표:

$$
W(C)=\sum_{h=1}^{H}w(B_h)
$$

현재 체인 $C$와 수신 후보 $C'$에 대해:

$$
\mathrm{Adopt}(C')=
\mathrm{Valid}(C')\land[W(C')>W(C)]
$$

$$
W(C')=W(C)\ \Longrightarrow\ \text{현재 체인 유지}
$$

현재는 목표값이 고정되어 있으므로 유효한 추가 블록 수와 누적 작업량이 비례합니다. 이 지표는 실제 투입된 전력이나 측정된 해시 시도 횟수가 아닙니다.

체인 교체 시 상태를 제네시스에서 다시 계산합니다.

$$
(U',S')=\mathrm{Replay}(C')
$$

따라서 채택하지 않은 분기의 보상과 거래 효과가 새 원장에 남지 않도록 합니다.

## 10. 저장의 원자성과 재검증

현재 상태를 $(C,U,S)$라 하면 후보는 먼저 검증하고 파일 저장 성공 후 메모리에 반영합니다.

$$
\mathrm{Validate}(C')
\rightarrow\mathrm{WriteTemp}(C')
\rightarrow\mathrm{Flush/Fsync}
\rightarrow\mathrm{Replace}
\rightarrow C\gets C'
$$

저장 실패 시 기존 상태를 보존하는 동작은 자동시험으로 점검했습니다. 재시작은 저장된 체인을 다시 검증하며, 손상 파일을 빈 원장으로 자동 덮어쓰지 않습니다. 운영체제 잠금으로 동일 데이터 폴더의 중복 작성자를 거부합니다. 모든 하드웨어·파일시스템 장애에서의 무손실을 증명한 것은 아닙니다.

## 11. 세 노드의 상태 수렴

노드 A·B·C의 보관 체인을 각각 $C_A,C_B,C_C$라 합니다. 현재 시험에서는 B가 A를, C가 B를 주기적으로 조회합니다.

$$
B\leftarrow A,\qquad C\leftarrow B
$$

시험에서 비교한 조건은 높이·마지막 해시·누적 작업량입니다.

$$
h_A=h_B=h_C
$$

$$
\mathrm{tip}(C_A)=\mathrm{tip}(C_B)=\mathrm{tip}(C_C)
$$

$$
W(C_A)=W(C_B)=W(C_C)
$$

2026-10-31 로컬 실행에서 높이 3의 초기 동기화, A 재시작·블록 추가 후 높이 5 수렴, B와 C의 개별 재시작 후 기록 유지를 확인했습니다. 이는 동일 PC의 세 프로세스 시험입니다. 위 등식은 해당 시험의 일치 조건이며, 임의의 장애나 적대적 네트워크에서도 항상 수렴한다는 정리가 아닙니다.

## 12. 오르큐브 참여 연계 — 향후 구상

기존 오르큐브 채굴자의 유효 참여 이력을 독립체인 참여 동기로 연결할 예정입니다. 추상적으로는 다음과 같이 표현합니다.

$$
\mathrm{VerifiedHistory}_i
\longrightarrow
\mathrm{EligibilityReview}_i
\longrightarrow
\mathrm{FutureParticipation}_i
$$

적격성·연계 조건은 미정입니다. 현재 노드의 합의, 발행 및 서명 검증에는 이 구상이 적용되어 있지 않습니다. 자동 전환·지급이나 교환 비율을 뜻하지 않습니다.

## 13. 구현·검증 대응표

| 수학 규칙 | 구현 파일 | 확인 범위 |
|---|---|---|
| 헤더·목표값·머클 루트 | headers.py | 해시 벡터·목표값·변조 검사 |
| 기초 보상 함수 | chain.py | 정수 보상·상한·저장 재로드 |
| 서명·UTXO·블록 재실행 | ledger.py | 송금·수수료·이중 지불·분기 재구성 |
| 후보 채택·저장·동기화 | node.py | HTTP 동기화·재시작·잘못된 후보 거부 |
| 두 프로세스 점검 | check_pc.py | 기존 보고서의 5개 항목 |
| 세 프로세스 점검 | 별도 임시 실행 | 2026-10-31 로컬 수렴·재시작 확인 |

v0.5의 자동시험 46개를 2026-10-31에 재실행하여 모두 통과했습니다. 수학식 문서화는 추가적인 보안 인증이나 새 노드 기능 배포를 의미하지 않습니다. 공개 P2P, 동적 난이도, mempool, 운영 지갑, ASIC 연결 및 양자내성 전환은 별도 개발·검증 대상입니다.
