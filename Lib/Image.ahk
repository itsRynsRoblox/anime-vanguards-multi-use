#Requires AutoHotkey v2.0

;GUI
global Minimize := "Images\minimizeButton.png" 
global Exitbutton := "Images\exitButton.png" 

;Roblox UI
OpenChat:="|<>*154$30.zzzzzzzzzzw000Ds0007s0007s0007s0007s0007s7zs7s7zs7s0007s0007s0z07s1zU7s0007s0007s0007s0007s0007zs07zzy0Tzzz0zzzzVzzzznzzzzzzzU"

AreaText:="|<>*125$38.zk000zzw000Dzz0007zzz001zzzs00Tzsbzzzzy8zzzzzU440Vzs1000Ty8U2E7zW80YVzsV090TzAMGG7rzzzzzy"
Disconnect:="|<>*154$122.zznzzzzzzzzzzzzzzzzws7szzzzzzzzzzzzzDzzzC0TDzzzzzzzzzzzznzzznb3zzzzzzzzzzzzzwzzzwtwzzzzzzzzzzzzzzDzzzCT7DVy7kz8T8TkzV0S7sHblnUC0k7k3k3k7U060w0tyQsrXMswMwMstsrD7CCCTbCDlyDDDDDCTATnntXnblnkwzblnnnnU3Dww0NwtwQz3DtwQwwws0nzD06TCTDDwlyDDDDDCTwTnnzXnb3nbADXXnnnnXr3wQSsss1ws3UA1wwwww1s31UD0C1zD1y7kzDDDDkzVsS7sHU"
UnitExit:="|<>*141$18.zzzxzvszVkTVsD1w63y07z0DzUTzUTz0Ty0Dw47sC3sT1kTVsznzzzU"
UnitExistence :="|<>*91$66.btzzzzzzyDzXlzzzzzzyDzXlzzzzzzyDzXlzzzyzzyDbXlUS0UM3UC1XlUA0UE30A1XlW4EXl34AMXlX0sbXXC80XVX4MbXX6A1U3UA0bk30ARk7UC0bk3UA1sDUz8bw3kC1zzbyszzzzzzzzbw1zzzzzzzzby3zzzzzzzzzzjzzzzzzU"

;Vanguards
EndScreen:="|<>*85$63.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzDzkDzzzzzztzy0zzzzzzzDzk3zzzzzztzyQMAnC9YsC7nW04MUA01Uy0F4UA1UUAzk48U16AslUy0U60Mlb7C3nWDk3UAw1gSQE6AQ1bU83nn1tblAz9Uzzzzzzzzzzzzzzzzzzzzzw"
VictoryText:="|<>*85$115.y3kQADzzVy7y67ks0S7zVsS67zzkz3z33kS0T3zkMD33zzsTVzVU0D0TVzwADVVzzwDkzkk0DkDkzy07kkzzy7sTsM0DwDsTzU7sMDzz3w7sA03y7zzzk3wC3tzVy1sC7Vz3zzzw3y700TkzU073kTVz3zy1z3k0DsTs07VwDkzVzzVzVw0DyDy07ky7sTkzztzlzUTz7zkDwzbwTwTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"
DefeatText:="|<>*44$92.wDzy0TVVzsTz3sDz3zz07sMTy7zkz3zk0zkUy67zU1wDkTw07sADVVzs0D3y7z03y71sMTy07kz3zk1zU0S67zU3wDkzwDzk03VVzsTz3sDz3zw00sMTy7zkw3zkzy3w667zU0A01zwDzVzVVU0M0300zz3zkTsMM0600k0TzkzyDzC601U0A0Tzzzzzzzzzzzzzzzzs"
FailedText:="|<>*46$83.U0EQkMsk300k1k00kkkkkkA01U0k01X1VVVUM0300k03y1z33zk0600kzzs3y67zVzwD0Vzzk3wADz3zsT13zz07sMTy7zkz207y47kkzw0DVy40DwADVVzs0D3y00TksD33zk0y7sE1zU0S67zU3wDkVzy00QADz3zsT13zw00sMTy7zkw27zkTVkkzw01U0ADzVzVVU0M0300sTy3z3300k0603kzyDzC601U0A0Tk"
LobbyCheck:="|<>*138$47.zzzzzzzzzzzznAzz0zzz2Nzy0zzyCnzwtzzszbztn1UUHC3n6200aM7UAslbAX70tlnCN0STnl6QnDwzbUQtW1tzDVtn63zzzzzzzz"
CreateMatch:="|<>*104$90.0000000000000000000000000000401w000700sC0C0T076000DU1gP0T0N0A30A08VV6l0F0FUM3zzTszt3VzlzlsNz1VkEQB11UUsEAFi10UE85010UEE4F2+A0MFb000kUE6FyC06Mk74EAlXlaMm+D4Mlx6k8lWFaA2/0UQM57l0skFaC39UkQQ5YNUssNa7ztzzzzxwTzzzzy1skTDVXsM6T37CM000000000000000U"
UpgradeText:="|<>*77$52.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzSTzzzztzstzzzzz7zXbzzzzwRyCEA04211st0k0E843nYE86840DAF0UMUE1w30k1k847sQ7UjUkMTzlwbzzzzzz7kTzzzzzyzbzzzzzzzzzzzzzzzzzzzzzzU"
MaxText:="|<>*80$41.zzzzzzzzzzzzzzzzzzzzzzzzzzzw/wxtx3sXllll7l33Xl7DW263kSTA0AblwyMWE71twlgUAFntXsC1lbnjkyLrDbzzzzyTXzzzzkz7zzzznzzzzzzzzzzzzzzU"
AbilityOff:="|<>*80$35.w1zzzzk1zzzz01zzzy03zzzw07zzzs0Dzzzk0TzzzU0zzzz01zzzz07zzzz0TzzzjzzzzyU"
ReturnToLobby:="|<>*176$121.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzztzDzzs7ztzzzzztzzwzzwzbzzw1zwzzzzzwzzyTzyTnzzyQTyTzzzzyTzzDzzDtzzzDC63DNAXy3kzbz3Uw7bjbY01bA60z1UDny0k60nXk2AVnaD4TVl7tz4MX4Mns34NtnDbDttlwzb4tbCFw1UQwtbnbwwsyTnWQnb1yQFyC0ntnyC8zDsX0M3kzD833UNwtz3UTUC1UA1wzbb3ltAySzlszk7XmSHyTzzzzzzzzzzzzzzzzzzyDzzzzzzzzzzzzzzzzzzzDzzzzzzzzzzzzzzzzzzz7zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
Retry:="|<>*174$46.00000000Ds040000zs0w00061k2M000M3zNzz71b7zbzyy6SQA6HDQNt00MAslU4N3Xlb60l6STYMM30tta3jb4TXbwDySE66TtzttkwNzbzzzzzzwTzzzzzznzzzzzzyDzzzzzzzzU"
Rewards:="|<>*87$66.zzzzzzzzyTzw3zzzzzzyTzw1zzzzzzyTzw0zzzzzzyTzwskNaQH9kQDwsU1a8300MDw0W90M310Nzw1280FXDCMDw10A0lXDCQ7wsXw0s3D0P7wsUAMs3D0E7wwkSNwHDmMDzzzzzzzzzzzzzzzzzzzzzzU"
StageInfo:="|<>*102$62.00000000C01ws0003U7k0lz0001g340MAntwwFyVy4L7zzzYTszlXUUE8B0446M88421E010bVAEM0I39X9gH420B0mMWEA8423EAb1a7X1Ukqr9sszjzmTtzzzw3UlQ6w4W8Q0001b000002"
VoteScreen:="|<>*84$65.zzzzzzzzzzzrnzTzzvzzrz7bwzzzbzzDzCDszzz7zyDyAUUUy44003yF010wc8003w4NA1sNW1nzw8WM7sn43bzssA8D1V070TtswMT3X1T1zzzzzzzzzzzk"

;Mists
ProfileText:="|<>*48$46.bDzz7wzyQkM84nUtX100HA3UAslbAX61nXaQm0tzD4NnAzbww3bAECTnsSQlUzzzzzzzzU"
VoteStart:="|<>*85$29.zzzzzzzzzzTDxzwSTnzwszXzsm223t4043kFYk7kW9UTXUkUzbXlVzzzzzU"
VictoryText1:="|<>*88$53.1y330wTsT3wC63zzky3kQADzzVy7VsMTzz3w63kkzzy7wADVVzzwDs0T33zzsTs1y63zzkzk3wC3tzVzkDsQ01z3zUTkw03y7zVzVw0DyDzbz7y1zwTzzzzzzzzy"
VictoryText2:="|<>*86$56.VzVVwC07VsTsMS3k3sS7y600w1y7VzVU0TUTVsTsM0DwDsS3w601z3zzUS3VsTkzzw00sS7wDsTU0S7kz3y7w0DVwDkzVzkDwzbwTwTzzzzzzzzzU"
DefeatText1:="|<>*61$53.Vzzk3wADz3zz07sMTy07y47kkzw07sADVVzs0TkMD33zk0z00S67zVzy00QADz3zw00sMTy7zkTUkkzwDzVzVVU0MTy3z3300tzyDzDD03zzzzzzzzz"
DefeatText2:="|<>*58$29.U0A013zsS27zky4DzVy80T3yE0y7wU1wDl07sTW7zky4DzVs80300E0601U0A0700M0zzzzzw"

;FindText Maps
PlanetNamek:="|<>*57$99.zzzzzzzzzzzzzzzzzzzztzzzzzzzzzzzzzzzy7zzzzzzzzzzzz00zkzzzzzzzzzztzk01w7zzzzzzzzzy7y007UzzzzzzzzzzkTk00Q3zzzzzzzzzw3y003UTzzzzzzzzzUTkDkQ3zzzzzzzyzw3y1y1UTs4731zw0S01kDkA3y00k03z01k0C1y1UTU0600Dk0601kDkA3s00k01w00k0C003UT0060070Q201k00Q3k60k70s7kQ3y007US1s61w70w3UTk01w3kTUkDUM00Q3y00TUS3s61w3007UTk0Dw3kD0kDUM01w3y1zzUS0061w30zzUTkDzw0s00kDUM1Vw0S1zzU30061w3U07k1kDzy0Q00kDUS00y0C1zzk3k061w3s07s1sTzz0zUUsTkzU1zUTzzzzzzzzzzzzzzzzU"
SandVillage:="|<>*59$77.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz7zsDzzzzzzzzw7z03zzzzzzzzsDw03zzzzzzzzkTk03zzzzzzzzUzU0Dzzzzzzzz1y1sTzzzzzzzy3w3zzzzzzzzzw7s7zzUEQA7zs8Dk7zy00k03z00Tk0zs01U03w00zU0TU03007k01zU0D006007U03zk0Q1UA1kC0k7zs0M7UM7kQ3kDzz0kTUkDUMDkTtz1Uy1UT0kDUzVy30w30y1US1y1s60061w3003w00C00A3s7007s00w00M7kC00Ds01w00kDUS00Ts07w01UT0y00zw0zy73Vz3z1VzzzzzzzzzzzzzzzzzzzzzzzzzzU"
DoubleDungeon:="|<>*57$107.zzzzzzzzzzzzzzzzzzzzzzzzzzzztzzlzzzzzzzzzzzzzzVzzVzzzz00zzzzzzzy3zy3zzzw00Tzzzzzzw7zw7zzzs00TzzzzzzsDzsDzzzk00TzzzzzzkDzkDzzzU00TzzzzzzUTzUTzzz0z0TyTzzzz0zz0zzTy1z0zU7y7wC11y1zU3w3z0y03s7kQ01w3y03s7y1s03kDUs01s7s03kDw3U03UT0k01kDU07UTw60070y1U01US0s70zkA3kC1w30Q30w3sC1zUM7kA3s61w61s7UQ3z0kTUM7kA3s43k00s7w3Uz0kDUM7k87U03kDk70y1US0kD0kD00DU00S0k7U01U01US1zz000y00D0030030A0ky003w00y00600C0A00w00Dw01y00A00y0Q01s01zw07y00M03w0w03s0Dzy0zz3VsMDw3w0Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
ShibuyaStation:="|<>*51$73.zzzzzzzzzzzbzkTzzzzzzzzVzU1zbzzzztzUzU0TVzzzzsTkTU07UTzzzs7wDk07kDzzzw3zzkD3s7zzzy1zzs7vw3zzzz0zzw3zs07s4601ky0zw03s0300kDU1y01s01U0M7k0700s00k0A3w01U0Q00M061zU0Q3w1UD0z0zw0C1y1s7UTUTzs70z1y3kDkDny3UTUy1s7s7kz1kDkD0w3w3kD0s7s00S1y1s00Q0S00D070w00T07007k1UT00DU3k03s0kDk0Ds1w01y0M7y0Ty1zUUzUS7zzzzzzzzzzzzk"
UndergroundChurch:="|<>*57$85.zzzzzzzzkzzzzzkzsTzzzzkTzzzzkTw7zzzzsDzzzzsDy3zzzzw7zzzzw7z1zzzzy3zzzzy3zUzzzzz1zzzzz1zkTzzzzUzzzzzUzsC67zkETU7sEETw600zk0D01s00Dy300Dk0700Q007z1U07k03U0C023zUk01k01UQ30F1zkM7Us70kT1UTUTsA7kQ7kM00kTkDs63sC3sA00sDw7w71w71w600Q7y1w3Uy3UQ31zy3zU01kT1s01UTD1zk01sDUw00s03Uzw01w7kT00Q01kTz01y3sDk0D00sDzs1zVy7w67s0y7y"
SpiritSociety:="|<>*56$80.zzzzzztzzzbzzzkTzzzwDzzkzzzk0zzzy3zzsDtzs07zzzUzzy3wDw00zzzwDzzky1z00TzzzzzzzzUTUS7zzzzzzzzs7s7vzzzzzzzzy1y1zz31z3kkQC01UDzU0DUM021U0Q0Ds01s600UM0700S00C1U0M601s03U01UM061U0TU0M3UM61zUS1zy061w61UTs7UTzy1UT1UM7y1s7yTkM7kM61zUS1z3w60s61UTs7UTUS1U01UM7y1s7s00M00s61zUS0C00C00C1UTs7k1k03U07UM7y1w0S01s03s61zUTU7s1y1bz3kzwDw3zzzUTzzzzzzzzzzzs7zzzzzzzzzzzy1zzzzzzzzzzzzUTzzzzzzzzzzzs7zzzzzzzzzzzy1zzzzzzzzzzzzkzzzzzzzzzs"
IgrisBoss:="|<>*56$83.zzzkzzzzzzzzwD01zVzzzzzzzzsS00y3zzzzzzzzks00w7zzzzzzzzUk00sDzzzzzzzz1U01kTzzzzzzzy30y1Uzzzzzzzzw63y31zs7zs7zwsA7w63z03z03zU0MD0A7w03w03w00kQ0sDk03k03k01Us1kTU07U07U031k1Uy0k60k60061k31w3sA3sA3kA3w63sDkMDkMDUM7s47kTUkTUkT0kDk8DUy1Uy1US1UT0kD0M30M30M3001U60060070060030C00S00S00A00D0S01y01y00M00y0y07y07y00s07y1y0Ty0Tz33zzzzzzzzzzzzzzU"
SpiderForest:="|<>*58$96.zzzzzzzzzzzzzzzzzzzzzztzzszzzzzzz1zzzzkzzkTzzzzzw0DzzzUzzkTzzzzzs07zzzUzzkTzzzzzk03zzzkzzkTzzzzzk07zzzzzzkTzzzzzUS7zzzzzzkTzzzzzUTzzzzzzzkTzTzzzUTzkkTkzkETk1y63UDzU0DUT00TU0w01k0zU07US00T00Q01k0DU03UQ00S00Q03s03U01UQ00Q1kA03y01UC1UM30Q3sA3zzU1UT1UM7UQ3kA3zzy1UT1UMDkQ00A3ztz1UT1UM7kQ00Q3zkz1UC1UM7UQ00w3zUS1U01UM00Q3zw3zU01U03UQ00S0kw3zU03U03UQ00S00Q3zk03U07US00T00Q3zs07U0DUT00TU0Q3zy0TUNzkzkMTk0y7zzzzUTzzzzzzzzzzzzzzUTzzzzzzzzzzzzzzUTzzzzzzzzzzzzzzUTzzzzzzzzzzzzzzUTzzzzzzzzzzzzzzUTzzzzzzzzzzzzzzkzzzzzzzzzzzzU"
TrackOfWorld:="|<>*50$65.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzjzzz00zzzzyDzzw01zzzzwTzzw03zzzzszzzzVzzzzzlzzzz3l72S3Xz0zy7UA0s36A1zwD0E0U68MnzsS7V12Q1kzzkwT72Ds7UDzVsyC4TkDUDz3lw88HUDkTy7Xs0E3440zwD7s0k6A83zwyDs3kQQk7zzzzzzzzzzzU"
ShibuyaAftermath:="|<>*57$82.zzzzzUTzzzzzzzzsTzw1szzzzzzzz1zzU71zzzzzzzw3zy0Q7zzzzzzzUDzsDkTzzzzzzy0Tz0z1zzzzzzzk1zw3w7zyzzzzz03z0001y0DkkTs0Dw0003k0S00zU0Tk000C00s03w21z0000k03U0TkA3w00060s601y1kDw3w7s7kM7zs70TkDkTUS1UTz001z0z1y0061zw003w3w7s00s7zU00DkDkTU07UTy000T0z1y1zy1zk7y1w3w0s1Vs7z0zw3kDk1k03UTs3zkD0zU7U0C1zkTzUw3z0T00s7zXzy7sTy3y07kzzzzzzzzzzzzzzzU"
GoldenCastle:="|<>*59$69.zw7zzzzVzzsDw07zzzwDzz1y00Tzzz1zzsDU01zzzsDzz1s00Dzzz1zzsD0S3zzzs7zz1k7wzzjz0zzsC1zzz0Ds7z11UTzzk0T0zU0A7s3w01s7s01Uy070070y00A7k0k00s7k01Uy061s70w1UA3s0kDUM7US1UTs63w30w7sA1z0kTUM7UT1k7s61w30w3kC0C0k60s7U01s0070070C00DU00s01s0k01y00DU0DU700Ds03y03w0w01zk1zw1zkDsAA"
KuinshiPalace:="|<>*55$65.zzzzzzzzzzzzzzzzzyTzzzzzrzzzsTzzz3y3zzzUzzzw3w7zzz1zzzs7kDzzz3zzzkD0TzzzzzzzUQ1zzzzzzzz0k7zzzzzzzy10TVz3kwA7w01y1w70k03s07w3s61U03k0Ts7kA3007U1zkDUM600701zUT0kA1kC01z0y1UM7kQ01y1w30kDUM41w3s61UT0kA1s7UA30y1UQ1s00M61w30s1k00kA3s61s1U01UM7kA3s3U030kDUM7sDU061UT0sTszksS7Vz3zzzzzzzzzzy"

;FindText Angles
namekAngle:="|<>*33$27.0000000000000000Dy003zs00zz00Dzs03zz00zzs0DVz03zzk0zzw0Dzzk3zzy0zzzsDTxz3zy7szzkDTzz0zzzw3zzzk7zrx0zyDs7zszUzzVy3zy7yU"
namekAngle2:="|<>*51$19.zzzzzvzznzz0Tw0Ds07s03s01w01y03zU7zzzzU"
SandAngle:="|<>*91$24.0007Q00DQzzzDUDzDzkDCDzmDs00U"
SpiritAngle:="|<>*125$19.zzzzzzztzzbrzzzzjzjjzvzzyrzzzzzrzzvzzzzlzTsDjy3rzUtzs1zy0jzUPzsCzy7ry2"
SpiderAngle:="|<>*25$38.000000E0000040+00Dv03s0Dzk0z0C3w07w60z02zX0Tk0bxUDw08zsDz03Dzzzk0Fzzzw04Tzzz01bzzzk0xzzzw0TTzzz07zzzzk3zwzzw0zz0Ty0zzk0zUTzw03kTzzU0SDzzs02jzzy00Tzzy007zzy000zzzU00DXzk003k2M80sM0D30S7U7kw7lDPw7nzkTzVzzw2DsTzz0bwDzzkDy7zzw3zVzzz0zlzzzkDwzzzw3zzzzz0zyzzzk7zzzzy"
TrackWorldAngle:="|<>*45$34.z8TzzHwVzzxDe7zzowcTzzHalzzzim7zzyq8TzzmHlzzy3P7zzkPATzy3Nkzzk9j3zyEhYDzn1iEzzMAl3zz0qIDzw2nMzzkCNXzz0v4Dzw79szzktBXzz0haDzw3gsTzsBrVzzUamrzy2r/TzsCuhzzUH/rzy0Nj0003AzzzzNXTzzxctzyvo7zzzzEn0A01q6RHACsnWNUr6QHA7sn2N4z6M2ArcnaNby7AnAvszyNrzDzzzzi"
GoldenAngle:="|<>*188$29.00xzy03zzw07zzs0Dzzk0TzzU0zzz03zzy0Mjzw107zs607zkM01zUk03z1003s2003kA007UM00D0k00y1U01w3UE3U7zy4ADzzssTzzzkzzzzUzzVz00A3z"
ShibuyaAngle:="|<>*36$26.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzlzzzk7zztwzzwvjzz8DzzUxzzsDzzy2TzzU3zzw1DzzU3zzw1zzzlzzzzzzzzzzs"
ShibuyaAngle2:="|<>*10$23.0D000zU01zs07zy0Tzz0zzy1zzw7zzwDzzszzzVzzyDzzsDzzUzzz1zzy3zzs0zzkFTz00Dy001s000k00008"
KuinshiAngle:="|<>*59$30.000000A000000000U000000000000010000100041U0021U0033U00D7k01z7s01z7w03zDzUDzDzzzzTzzzzTzzzzDzzzzDzzzzDzzzzDzzzz7zzzz7zzzz3zzzz1zzzz0zzzw0Tzzs0DzzkU"

;FindText Starter cards
CardsPopup:="|<>*36$22.zzzzTzwt3Y3cAU4aGNGMNZ9VaIkD3P0wBbzza"
CardsPopup2:="|<>*68$54.zzzzzzzzzzhyzzzzzzUBwzTzzvzUBwzDzztzD94C4Ak0VD84604001D8QD96111U0070D003k10b4DA8VzzzzzzzzzU"
ExplodingCard:="|<>*26$41.zzzzzzzzzzzzzz0zzszzY1zzlzy8zzzXrwEQE1630UQ42A210wMUFUWDkF0W1410UMUkA3RVlXkzzzTzzzzzyzzzz"
ThriceCard:="|<>*28$39.zzzzzzw03zXzzU0TyTzzXXzzzjwQ20EETbU0221wwMA3UDbX1UQ3wwMAEETbr/r73zzzzzzw"
ChampionCard:="|<>*9$40.zzzzzzzkXzzzzw0DzzzzlczzzzyDUM00UMy0U001XskE9UX6X10a2A0AU2M1sAn19UDzzzzzXzzzzzyDU"
ImmunityCard:="|<>*33$38.zzzzzzwzzzzzyDzzzzzXzzzzzs040FU60000M0UH1A6384kH90m1A4m0Aqn/AkLDzzzzzy"
RevitalizeCard:="|<>*20$37.zzzzzzUzzwPzUDzzNzl7TzwTsm2QU40006E2000E8a800QAH438CC8E/a7biADzzzzzzzzzzzzU"
QuakeCard:="|<>*36$37.zzzzzzzzzzzzwDzzXzs3zzlzwEzzszySFY0G3T8m011bYM810HX840UM0UE08C0MA4Y7zzzzzzU"

;Portals
SelectOneReward:="|<>*108$211.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzXzXzzrzzzzzzzTzsylzzv7zzzzzzzzzzbzzUzlzznzzzzzzzDzsSMzztXzzzzzzzzzznzzWTszzszzzzzzzXzwT4TzwFzzzzzzzzzztzzsw4MA0D10kT160w4701Uw04463kEH9010VDw60A207U087U30S03U0EC00210s804U0U2XzU040DDX1U3X1YyAbtX07aA600QM2021W8TzM0W17Xl0k3l4WD4HwFU7l630USA30F0l67z0kMUkEw4N1w613kNy0m3s31kMD71mA0Q00TkMAEQQT3AUz3UlwAzWN1y9YsA7nUtj1D12Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs"

PlanetNamekPortal:="|<>*79$26.2Tzyk7zzgVU602G40nY10YxWK9U"
namekWinterAngle:="|<>*90$71.00000Dz7w3z000000zy7w3y000001zy7w3y000001zwDs7y000003zwDs7w000003zsDs7w000003jsTsDs000004DsTkDs000000DkTkTs000000TkzkTk000000TkzUTU000000TUzUz0000000zUzUy0000000zVz0w0000000z1z1s0000001z1z1k0000001z3y3U0000001y3y300000003y3y200000003y7w400000007w7w000000007w7w000000007sDs00000000DsDs00000000DsDt"
namekWinterAngle2:="|<>*72$25.zs3zwQ1zyA0Tz00Tz00Tzk0Tzs0Tzw0Tzy0Tzy0Tzy0Tzy0Tzz0zzzUzzrkzzsszzwAzzy2zzzXzzztzzzyzzzzzzzzxzzzyTzwz6Tw7k"

ShibuyaAftermathPortalLobby:="|<>*74$32.WQDzzkbnzzwME92EmE8G92Y0UW290ABlzzzyTs"
ShibuyaAftermathPortal:="|<>*82$32.WQDzzkbnzzwME92EmE8G92Y0UW290ABlzzzyTzzzzjy"

ShibuyaPortal:="|<>*76$35.zzzzzzzzzzzzWQDzzy4yTzzwME92EyG12F9mY0UW3l81ViDzzzyTzzzzxzs"
shibuyaWinterAngle:="|<>*64$30.zzzzzzzxzzzzkzzzy0zzzk0Tzz03zzs0Tzz01zzz0Dzjz1zwzz7znzzDyPzzzn3zzyDVzztzlzzDzlzzzzkzzzzkzzzzszzzzszzzzsTzzzsTzzzwTzzzwTzzzwDzzzyDzzzyTzzzzzzU"
shibuyaWinterAngle2:="|<>*71$25.zzzzzzzzzzzzzzzzzzzzyzzzz7zzzUzzzk7zzs0zzy07zyk0zza07zwk0zza07zwk3zza3zzUlzzkbzzkxzzkzzzsTzzzTzzzzzzzzzzk"
shibuyaWinterAngle3:="|<>*85$117.zzzzzzzzzzzzzzzzzzy7zzzzzzzzzzzzzzzzzzyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw3zzzzzzzzzzzzzzzzzy01zzzzzzzzzzzzzzzzy001zzzzzzzzzzzzzzzz0001zzzzzzzzzzzzzzzU0003zzzzzzzzzzzzzzs00007zzzzzzzzzzzzzw00000Dzzzzzzzzzzzzz000000TzzzzzzzzzzzzU000000zzzzzzzzzzzzs00000001zzzzzzzzzzy0000000007zzzzzzzzzU000000000Dzzzzzzzzw0000000000Tzzzzzzzz00000000000zzzzzzzzk00000000001zzzzzzzw000000000007zzzzzzz000000000000Tzzzzzzs000000000001zzzzzzy0000000000007zzzzzzk000000000000zzzzzzw0000000000003zzzzzz0000000000000Tzzzzzs0000000000003zzzzzy0000000000000DzzzzzU0000000000001zzzzzw0000000000000DzzzzzU0000000000001zzzzzs0000000000000Dzzzzz00000000000001zzzzzs0000000000000Tzzzzz00000000000003zzzzzs0000000000000Tzzzzy00000000000003zzzzzk0000000000000zzzzzy0000000000000Dzzzzzk0000000000003zzzzzy0000000000000zzzzzzk000000000000Dzzzzzy0000000000003zzzzzzk000000000000zzzzzzy0000000000007zzzzzzk000000000001zzzzzzy000000000000Tzzzzzzk000000000007zzzzzzy000000000001zzzzzzzk00000000000Dzzzzzzz000000000001zzzzzzzs00000000000TzzzzzzzU00000000003zzzzzzzy00000000000Tzzzzzzzk00000000003zzzzzzzz00000000000Tzzzzzzzs00000000007zzzzzzzzU0000000000zzzzzzzzw00000000007zzzzzzzzk0000000000zzzzzzzzy00000000007zzzzzzzzs0000000000zzzzzzzzzk0000000007zzzzzzzzz0000000000zzzzzzzzzy000000000Dzzzzzzzzzw000000001zzzzzzzzzzs00000000Dzzzzzzzzzzk00000001zzzzzzzzzzzU0000000Dzzzzzzzzzzz00000003zzzzzzzzzzzz0000000zzzzzzzzzzzzzU000007zzzzzzzzzzzzzk00001zzzzzzzzzzzzzzk0000Tzzzzzzzzzzzzzzk0003zzzzzzzzzzzzzzzk000zzzzzzzzzzzzzzzzk00Dzzzzzzzzzzzzzzzzs0TzzzzzzzzzzzzzzzzzszzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"

;Sand Portal
sandPortal:="|<>*75$24.zzzzzzzzzzzzwTztsTztss1VyG49tE41wMYXzzzzzzzzU"

ShibuyaStationBackupAngle:="|<>*101$89.03zy00000003zz007zw00000007zy00Dzs0000000Dzw00Tzk0000000TzsDrzzU0000000zzzU1zy00000001zzU03zw00000007zz00Dzs0000000Dzy00Tzk0000000Tzw00zzU0000000zzs01zz00000001zzk03zy00000003zzU07zw00000007zy00Dzs0000000Dzw00Tzk0000000Tzs00zz00000000zzk01zy00000001zzU07zw00000003zz00Dzs00000007zy00Tzk0000000Tzw00zzU0000000zzs01zz00000001zzk03zy00000003zzU07zw00000007zz00Dzs0000000Dzy00TzU0000000Tzw01zz00000000zzk03zy00000001zzU07zw00000003zz00Dzs00000007zy00Tzk0000000Dzw00zzU0000000Tzs01zz00000001zzk03zy00000003zzU07zw00000007zz00Dzs0000000Dzy00zzU0000000Tzw01zz00000000zzs03zy00000001zzk07zw00000003zzU0Dzs00000007zz00Tzk0000000Dzw00zzU0000000Tzs01zz00000000zzk03zy00000001zzU0Dzw00000007zz00zzk0000000Dzy0E" ;148, 86, 274, 156
