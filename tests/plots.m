%plot kleines Fachwerk
x = [1:62];
y1 = [0.0320199028868231;-0.0154725384825662;0.134189850359612;-0.154055223481860;0.0901001628433498;-0.161078693504632;0.0629649798519554;-0.181682416193190;0.00598347224079100;-0.204138836423690;-0.111218562408888;-0.246524274649729;0.261356230696452;-0.381449901422455;0.166620073020913;-0.398814725721801;0.0920573592751452;-0.432000312572811;-0.00796207351395555;-0.469664886717442;-0.180051686591738;-0.502638129375637;0.371157786733947;-0.672081781859193;0.227319220646812;-0.696381273906571;0.116670751404714;-0.727450924036306;-0.0172162877822654;-0.758735942110386;-0.215911568116393;-0.782297509385210;0.456659850724064;-1.03569210518696;0.281248210190354;-1.02457244268655;0.141068775589937;-1.03212863714512;-0.0187470512513202;-1.04610420223193;-0.228209882366223;-1.05725206804407;0.503281577214588;-1.32632656917476;0.316501342774924;-1.30451211398392;0.159047429146917;-1.29853879994091;-0.0174501154457057;-1.29954276101068;-0.229360330803912;-1.30069320944837;0.521717758895954;-1.56187392644927;0.335913334211654;-1.53031010813064;0.170048807591133;-1.51815828124873;-0.0162996670080164;-1.51700783281104;-0.229360330803912;-1.51700783281104];
plot(x,y1,'.')

hold on 
y2 = [0.0283594500415842;-0.0203024335188097;0.148734495101041;-0.161941931602884;0.0598205747560148;-0.166611465559156;0.0689643176254067;-0.201024986247792;0.0129541456940156;-0.243132536494151;-0.112114082588692;-0.273549002744350;0.292799456245810;-0.478977623189832;0.154387271491952;-0.507045263901528;0.105722168564598;-0.539597262807990;0.0201370563747361;-0.577861658069757;-0.193811698927186;-0.627219013660673;0.408796776741005;-0.846386074021595;0.239985247075059;-0.861399948647774;0.136767623829780;-0.913112743639901;0.00513403719145562;-0.965768433647410;-0.226151959494803;-0.981965842910651;0.509780222610021;-1.28806724572620;0.303898181433206;-1.29352998683017;0.167341631462220;-1.29623291197916;0.0103918986531245;-1.31013608448011;-0.242294810799179;-1.32748033468521;0.555300927307107;-1.66718795355053;0.373330747437664;-1.63879982735584;0.186715391386689;-1.63078100129905;0.00876760757458319;-1.62759969974409;-0.241093412270878;-1.62639830121579;0.579209758198886;-1.91230322393234;0.383668317541342;-1.88621205482412;0.203670388728168;-1.87045845581958;0.00756620904628232;-1.87165985434788;-0.241093412270878;-1.87165985434788];
plot(x,y2,'.')

legend('u_{FEM}','u_{FETI-DP}','Location','southwest')
xlabel('Verschiebungsfreiheitsgrade')
ylabel('Verschiebung')