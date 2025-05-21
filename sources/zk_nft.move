module zk_nft::nft {
    use sui::groth16;
     use std::string;
     use sui::url::{Self, Url};
    public struct AgeVerifiedNFT has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        url: Url,
    }
    #[allow(lint(self_transfer))]
    public fun mint_nft(
        name: vector<u8>,
		description: vector<u8>,
        url: vector<u8>,
        verifying_key: vector<u8>,
        proof: vector<u8>,
        public_inputs: vector<u8>,
        ctx: &mut TxContext
    ) {
        verify(verifying_key, proof, public_inputs);
        let nft = AgeVerifiedNFT {
            id: object::new(ctx),
            name: string::utf8(name),
			description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
        };
        transfer::transfer(nft, ctx.sender());
    }
public fun verify(
    verifying_key: vector<u8>,
    proof: vector<u8>,
    public_inputs: vector<u8>,
) {
    let pvk = groth16::prepare_verifying_key(&groth16::bn254(), &verifying_key);
    let proof_points = groth16::proof_points_from_bytes(proof);
    let public_inputs = groth16::public_proof_inputs_from_bytes(public_inputs);
    assert!(groth16::verify_groth16_proof(&groth16::bn254(), &pvk, &public_inputs, &proof_points));
}
#[test]
fun test_groth16_bn254() {
    verify(
        x"94d781ec65145ed90beca1859d5f38ec4d1e30d4123424bb7b0c6fc618257b1551af0374b50e5da874ed3abbc80822e4378fdef9e72c423a66095361dacad8243d1a043fc217ea306d7c3dcab877be5f03502c824833fc4301ef8b712711c49ebd491d7424efffd121baf85244404bded1fe26bdf6ef5962a3361cef3ed1661d897d6654c60dca3d648ce82fa91dc737f35aa798fb52118bb20fd9ee1f84a7aabef505258940dc3bc9de41472e20634f311e5b6f7a17d82f2f2fcec06553f71e5cd295f9155e0f93cb7ed6f212d0ccddb01ebe7dd924c97a3f1fc9d03a9eb91502000000000000003d8a4532b813e7fd900371be9e7663b768c5d72aa1fa7e8c695450446d1e7310a5f29847333b9b982005b77b6d9acc1a19ee1ea16e97056caa67b6f15462d329",
        x"251ad0a0e98440d9661b04c61df4d7ceca43e67da9d1052f351200e1a334fc041fe7ffed2701b263dd5c0c806f464e49e0874187a65a958c537de24b1cbd4d1178ed942e5b6ea040e54fb416227761ed3c79ded53ebb814bdb85cf4f21a48e1c6d1510cc4afcebad96f9319b77be01c3adf1851f76e61ffc285bd4debc53d220",
        x"0100000000000000000000000000000000000000000000000000000000000000"
    );
    
}
#[test]
fun test_mint_nft() {
    let mut ctx = tx_context::dummy();
    mint_nft(
        b"test",
        b"test",
        b"https://test.com",
        x"94d781ec65145ed90beca1859d5f38ec4d1e30d4123424bb7b0c6fc618257b1551af0374b50e5da874ed3abbc80822e4378fdef9e72c423a66095361dacad8243d1a043fc217ea306d7c3dcab877be5f03502c824833fc4301ef8b712711c49ebd491d7424efffd121baf85244404bded1fe26bdf6ef5962a3361cef3ed1661d897d6654c60dca3d648ce82fa91dc737f35aa798fb52118bb20fd9ee1f84a7aabef505258940dc3bc9de41472e20634f311e5b6f7a17d82f2f2fcec06553f71e5cd295f9155e0f93cb7ed6f212d0ccddb01ebe7dd924c97a3f1fc9d03a9eb91502000000000000003d8a4532b813e7fd900371be9e7663b768c5d72aa1fa7e8c695450446d1e7310a5f29847333b9b982005b77b6d9acc1a19ee1ea16e97056caa67b6f15462d329",
        x"251ad0a0e98440d9661b04c61df4d7ceca43e67da9d1052f351200e1a334fc041fe7ffed2701b263dd5c0c806f464e49e0874187a65a958c537de24b1cbd4d1178ed942e5b6ea040e54fb416227761ed3c79ded53ebb814bdb85cf4f21a48e1c6d1510cc4afcebad96f9319b77be01c3adf1851f76e61ffc285bd4debc53d220",
        x"0100000000000000000000000000000000000000000000000000000000000000",
        &mut ctx
    );
    
}
}
