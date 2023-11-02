import 'package:chia_crypto_utils/chia_crypto_utils.dart';

void main(List<String> args) {
  for (final serializedOffer in [buyUsdsOffer, nftOffer, buyChiaForUsdsOffer]) {
    final offer = Offer.fromBech32(serializedOffer);
    print(offer.offeredCoins);
  }
}

const buyUsdsOffer =
    'offer1qqr83wcuu2rykcmqvpsxygqqemhmlaekcenaz02ma6hs5w600dhjlvfjn477nkwz369h88kll73h37fefnwk3qqnz8s0lle09qtck70509n6h9w5t6mc52mnuv0aa8eq9amtje6kjy3cwlym65xe6z2qyku489nmflf5jhc3yyavtny7uwlcqm28tphypu3em5fqaltthu07n8humu4wu50ksgqken2yrahj8fhagmpf8fsukde0daal9rl8gk7ah2tuke2h0xkh0z3vwtmttz2lwapy34dwld6tamllwtusm4j2adlfw3pw89dldctr68y47mc7fkp5f85cpvk053smd73cmd73cmdk3cmdknccd857gcdklarthjqshac9umanufauddknfh3kxuex5shwj9vvdagpueeawpkxa5xwekjayw442p24jcalt4hrkrr44pdhv0hkc52j986kyzhjfxxgj0curlt28awphhjxjfa54fq2acyx7vdrevxprdtqdauygmy3l2uhwyupj809h94th4vx348wmxclawmcjkya6fy4r824vcd8paty2m37mputhxva6f5fulpvvm6pqc6yqxnvlut3q6hml4h3990cfavpnjzv5p55whpema02e9c5m7f28xr00huf95czh62dnh0adf04nnjvd348avljyyc2t68uy7kqcey6ehlst8jfyt0xe5ke4g269d7eymwmz6fg8t98z2ejvryh4l0ncu9lsfsg8qq4tk0ltlst8537lh305ku48uup8ynk43tlznhlhd6kh3a7a0kn2l7l8ghs6jfksljgmlctggh9mhfzy3kme6mtta4ndca648rn0x7lpy5ykhl979jl0jf0faz3w6gnzytvm0h6eud0utlqpmt7ck2l0hugxh8q9ufu0w5s6thplwvar58mn4daq5jdkrnjdspkdws9sndxelchzp4t2qgtr2tsdgjvnfe7ap6dlwwcpnc4sxh4a8hew6uxwm7hmw65lh4s740wah4cwprvje3n3py6q58gjjwjvlhq7wah8mnvme8l9wtym4mlvd2d26d68vzxwrlfx0an4ktnxmac0fyxlh3pkx93v9muc49wxzj4txmxe706lqzz0ga0697auf6eeu67hptll7l49kc3n9u8ak4xp5qetnu2w60tdnvdlsv0rnxlwf46h54x9sqxvaf2aqrqerfg';

const nftOffer =
    'offer1qqr83wcuu2rykcmqvpsxygqqemhmlaekcenaz02ma6hs5w600dhjlvfjn477nkwz369h88kll73h37fefnwk3qqnz8s0lle0wrnns28ju6tnanu7x4dhl84m6ne7lzma68uhtvuky7dlmwaft9vn08g04qj8n54xpkdcupyaj45ru97hrevaghlnum86mrp8pkgmhfr2vcums20vlt0ud7jufz2c2qtve73m2xdn6evd4wmapdv0ysu865juy5mvc0tuc8eh9fnaa8f8rscnzkn92up7kskack7mr8ull5hkt25c6rt3jyx209nfr76mj6yah8h3ey6egsar3ug3vl6gvdl2xve95vejtl68va9gdczvpyjx6tagtaj3f08lamzs0a6wwwexmw5nujl0hj8esnlq3y6cwx4ahjf0km2velaluz6t9zy029d54m6dpc5emeunt540gueaxd43ms7khml0g59v0atd8qg9auleg2neqcjpcj8mjehmfeks7gazhwlz4ffam6ukt3wwddlya3qah92s4wgqhr73lyva5fyq68uencfm8up5auqtzmuvure07v84jch8vzcwldm0qdf4uwatuj4xtjfxadlp37x8xf8nupxtz7jl7reyv62fg9q5t057kfe95e2jdftx5etj2f6k2kjfdx48zmjwdx55j4jfwf4xzj24295hnxd7gfz425j72x99jc2kf9py56dxtxu62an2g4lxzkvwsegk5s27hed9j52f0eqhykn206h9vnnxt66mtpvf46s4ujjsx8v4k8swtwhfwc8w04mvxeyn4hd66p5w9aeekxpre6uteakglkm6ull6f5c4dnll7dl9qfwex3zm6ajptel8qxwa89qrks4g2ejku4jzdflxzkn759dy5jqjc27wqvxng95hsryderq9zcd7ma6h9gakc7s7k3c5txcswaxlz0ylykadhaqkmch2kusflvdvgrrjtmrq9ft56lkyhem7hsl0gjwtd99r2klhuxx3vxj7z86k79aalhrmuw9u8cqpd5llh270m4qh8kdw26mllnwdeg92mwnuamx6kem0zpym70tzh9m8t6adard9tqwemw6rey76xumh5dehwpxu7dlhfm5wmpu29n7urkjwcwa6lf27t7j4pnfzr6hhz7wr3mm59t07y6utwnzulnv8s29w6dka2dtcx2nmk3j2rwu9tw764e220xt4nw3p27hzsm9l00zacg2kvp4u95jas6e6fvq5jx3hxe9rwdjyxcvwaslemwm8pwpy709nmmlycj85k6xuqt93460f4echndafew6rknmymn3cv96ljqmyrqte3gt4gr8gxwcs944smk6a9dsgxdmvdhmzcmxc4eh09lxkkk7gl5h2e46ukd3t2sh6s54l02uj5t8ja7lh2nuyd7knzhd9y4dtnjmj4wc93atltz5anqz2lhlmlcxrj433kh4070tda7f9kk774mdz6g548nakuaxh9xeqce4l0jysn07umlc9wa8xh4a77xdpe3ksn0sruewe5f2nz9cmeuatlljs6che7wud2dpxqzwcvkstz2dsswqu6dcsqvlweduq6zvzcfp0qzahjpz4sfxz034cllm079egj6umglv7x9uar83lkwjewjavp75dnjf6x93wm9c84x4q5xd8q5x4asajdj3e3lylkp832vtvk9f38jlv5n9xadnvk8utlgd45kkzkea75rn7ljvmelmg0hxw2sla7ad86zrv27rfrda440wplla38wnzpjxa3cmdxentdxs6qj6mc2le5kc5pexh5d4zh8g9ul65edeajdxlyv4hx8t8y5xapcq2qus0muqxazdr';

const buyChiaForUsdsOffer =
    'offer1qqr83wcuu2rykcmqvpsxvgqqa6wdw7l95dk68vl9mr2dkvl98r6g76an3qez5ppgyh00jfdqw4uy5w2vrk7f6wj6lw8adl4rkhlk3mflttacl4h7lur64as8zlhqhn8h04883476dz7x6mny6jzdcga33n4s8n884cxcekcemz6mk3jk4v925trha2kuwcv0k59xl377mx32g5h2c52wfycczdlns04vgl4cx77f6d8xs4f3m23zpghmeuyfzk2sj30xtamfnhy2n7nt8k4sk44l09mjhg2j2ju0rn6zqml4kryms5htsqy44p0ke6hxzj08jul6d8twjcdmakkafxn70330zyadkey9h7at0a3uhrhle5xv725g2qrm9uwre2vhzlm8w2rka5wuyk6vqsewtwpg0dapa35d3x0e9u7k2rdu4ldthuyyuj47detvnr4hx04cms79t7whhdzexmzlala8vne072zxmhy8shqqvnzf2egqw63tvcu2l4qrrw7xrxk0agznndgevmwwu6lammkr8lxck7z9k654nnwj2cewdxcma22n7huh00nxmewl3mth7uamk39phhfnmsz6rvsvnl0lstelhmaa3hc4jax0jma6hskw600dkjavf3n4774kkr3798887lljshn7l6lcmcw9jkjsyrzqp5m079uge75mldrtl7zu2vkuec8ec2ck6nd2gn06ndcetrt0k8jax0uzhuf5zm4jl7l6ql0nt35ehmpez48zmfhamvnkfvkmhj5qh98dtakme7tsjk80y7v7feczs20ftqtzfl7mnhvra5mh7x7x6rsh0gksyne4zjldehn87duatrfdr447umw4wkvefmaqkw3yn6kwvf7llzcny5jl7xdw3ea2kfep7dwtpaa3eyygmmddr4fyy7hh0ewa583sg9z8pkd2pzq4xcjll7d7t8hkpp0rq42yees92w0lyw3l24n9h6shl8jahhu8q5e52fkdhljlupl0t5hxghwz625760v7um276llz6ma7ndehfvh7g28zlx7endtk62gylw50nhallezexjhcsgnfwjr2tm8a487f2ah7zv0t9t8eujuaxw42085cwkdl8hh7q2k4m565l8lwdtll98qvdan8am5e0ea07pl3qu6j0pa2zlh06uz306h87jttd8mmku4whyrzvjtlfnjc38njv2aln7d776h046ltupqq35lyargfztr5l';