import 'package:magic_flutter_v2/modules/blockchain/supported_blockchain.dart';
import '../base_module.dart';

class BlockchainModule extends BaseModule {
  SupportedBlockchain blockchainName;

  BlockchainModule(provider, this.blockchainName) : super(provider);
}
