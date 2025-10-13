// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PoolLens, PoolInfo} from "src/PoolLens.sol";

contract PoolLensTest is Test {
    PoolLens public poolLens;

    function setUp() public {
        vm.createSelectFork(vm.envString("BASE_RPC_URL"));
        poolLens = new PoolLens();
    }

    function test_volatileAMMFactories() public view {
        address[] memory pools = new address[](72);
        pools[0] = 0x48759F220ED983dB51fA7A8C0D2AAb8f3ce4166a;
        pools[1] = 0x8aCB107293eE6Ab358327b5fbb8051183fa3862F;
        pools[2] = 0xb217dA64836DDB800559ac3369f702ee1DB0E1e5;
        pools[3] = 0xd7B0067b7fDCbb26DbfaD4Ceb617C8dCf4b170F2;
        pools[4] = 0xE4faa73134C66832c272f067adC401f0963A9D7a;
        pools[5] = 0x23AD201B84d007ba8cc4aF789010CC703f6acD86;
        pools[6] = 0xAaCE080ea9CE5e7942Ea826d311b6170BdfCf73B;
        pools[7] = 0x48EAB07DC303ad02DDB9Ff2733ba881F6A1b8D64;
        pools[8] = 0x5fBC09191Ae0659167d9550EAbdf499b80AD01Af;
        pools[9] = 0x83240b049Fa89b65be714aeD68e5B074df6aAc84;
        pools[10] = 0x2F48C208d7Bd2b4Ff6Da005A9427eF38F035b2d8;
        pools[11] = 0xd16Cc119b7c113660580291580cbEB588C9e2653;
        pools[12] = 0x6cDcb1C4A4D1C3C6d054b27AC5B77e89eAFb971d;
        pools[13] = 0xf4252049D23ea05aDe29AB6f24A490c6804038d7;
        pools[14] = 0x12cf9a7818d6b38FD76D1a85731D97D0A04DBadF;
        pools[15] = 0x76e447CeC8649Dc4D296c4019D3e2D7a22ea9A20;
        pools[16] = 0xf207d02BECD4417aAA3383804b6B87b17602c86D;
        pools[17] = 0x9941dfa4d724fd7a2E5E5d9777560b20de98cE0d;
        pools[18] = 0x239f67C394460f0B09E0FE8e62C089E3F7CEA842;
        pools[19] = 0xA6f77321B8726FaAB89B72f28C2603b667448BC2;
        pools[20] = 0x995985C9027E8a90C823a5E0a9112Fea72d1F4DD;
        pools[21] = 0x84e6bEA6Efe00399B6697fE9BE3D303FCf3F4f8e;
        pools[22] = 0x41fe2f2FD39E87E7e92a62E04e689bE807066A44;
        pools[23] = 0xe2e75836CD77ACaFc7523F95B9c223437Fa80B24;
        pools[24] = 0x0DFb9Cb66A18468850d6216fCc691aa20ad1e091;
        pools[25] = 0x69bc1d350fE13F499c6AedEd2C5eA9471b2a599A;
        pools[26] = 0x3eb38981d54BAA23a86c3E017A6B3b47F977dE72;
        pools[27] = 0x637ad8d2611d3efE2ef41fdBb40b9F21AbAF9585;
        pools[28] = 0x08Df03512DaD349076267706eB7e9f1d3b645AA3;
        pools[29] = 0x99473274F8DDdE2D736F548D2D6F916BF00dD9f5;
        pools[30] = 0x3110ad47E4c0d72E5E5Abcbe0A4e73319D023fb3;
        pools[31] = 0xeF6F90aCDa6e8102093F3F4e28D952B0276E4ABB;
        pools[32] = 0x60D1CEBd97A6168516f35982d499CDf8a452Abb3;
        pools[33] = 0xA031fE784fC24355b1Aab9f9A2aBB55A324d07B5;
        pools[34] = 0x43BBb129b56A998732767725A183b7a566843dBA;
        pools[35] = 0x16f7e8199B46Ff86D33be983Ee6c642d9c14A5ae;
        pools[36] = 0x889339213a0CC0a795F69cae5b1Db2223f944A4E;
        pools[37] = 0xa5BF9053FD626d35bf2B7847b38006D1759f5967;
        pools[38] = 0x05e91B5caDB45832e953131bC6165CD63fe9c1A1;
        pools[39] = 0xe13fF4186896D5923D6A684254906Eb279F225cC;
        pools[40] = 0x2f816A37b65f99F63e5a04189E24D0dcB256fBb6;
        pools[41] = 0x010b6af33c8a6Ef8d2C47d67EC2b213CBFB90C16;
        pools[42] = 0x5E14319D52c9C18a04BFBBE12dd3a0FE3C1A816a;
        pools[43] = 0xBaEF1Dd7620D11ccdE12581C368034eef39Dc40a;
        pools[44] = 0x49508923Bafdc214B6556A7F6206cbc0F93C9988;
        pools[45] = 0x3e025C4BC807F151765bc397be04cc852EeE1485;
        pools[46] = 0xF3706dc080C93d0cb597a1ec57dCA1Ffeef06c84;
        pools[47] = 0x2EF87244BE5C18cfcBBEfBcE3e1c768A58Ae18e0;
        pools[48] = 0x9DFf4b5AE4fD673213502Ab8fbf6d36015efb3E1;
        pools[49] = 0x2C4909355b0C036840819484c3A882A95659aBf3;
        pools[50] = 0x594b83709464A83F37aC77E69DDD447a8A33c0EE;
        pools[51] = 0x6e3fbff8bE1d2122D8eC9aaC103a167f307c668B;
        pools[52] = 0xAeB9b7c93D662dEefBbd4675D8b17A1f8FF20860;
        pools[53] = 0x1c3FCeA97a3161434901097878faF90227cD3394;
        pools[54] = 0xeD445A77E75F18B04818d940d0E490C15C6072B7;
        pools[55] = 0x7Cf66E57c5D3E8850d4A15ABF7fd47C3d8538d10;
        pools[56] = 0xd6B1fF961077C740929ad23bA5438E63749c1c31;
        pools[57] = 0xbB345D35450BF9Ee76F3D2cE214E8e7AC5e1071d;
        pools[58] = 0x209fea2035D0DE5431fF98Ca18962E4924D6db03;
        pools[59] = 0x37E769D2dcF3e3E8dFC37c0Df83EEB56edfC0fD2;
        pools[60] = 0xF3D4F0809ffAEEC292591ad655c2d3eFaFD58355;
        pools[61] = 0x83C259821b181Ce36768f4347DA3892fA0B11103;
        pools[62] = 0x1DDa8b6469df243971381f1f3F4137814ca68722;
        pools[63] = 0x7149a871339E175A1bDBBE84a3E98C0B4bCC46dF;
        pools[64] = 0xb909F567c5c2Bb1A4271349708CC4637D7318b4A;
        pools[65] = 0xd9eDC75a3a797Ec92Ca370F19051BAbebfb2edEe;
        pools[66] = 0x3667af77FF1481aca513d2C97A32C0ac31ba813D;
        pools[67] = 0xcEdF590857aE7Fbd4A342Ce9Ee9CA111570A1ca2;
        pools[68] = 0x74F22A01Da78294f8dF640C98A414FE209e33f60;
        pools[69] = 0x6466e1a3b42Ef91f8f7C135970db4495e89F9C0A;
        pools[70] = 0x4910C78a1C75E36548F1f2f1f4dCb71A4F69fC07;
        pools[71] = 0x4660Ff55A4Db144734AE76550Ee3093e0BA7F8D1;
        address[] memory factories = poolLens.batchFactory(pools);
        for (uint256 i = 0; i < factories.length; i++) {
            console.log(address(factories[i]));
        }
    }
}
