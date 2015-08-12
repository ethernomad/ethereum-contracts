contract Mailbox {

  struct Message {
    uint64 time;
    string contents;
  }

  mapping (address => bytes32[]) hashes;
  mapping (address => mapping(bytes32 => Message)) messages;

  event NewMessage(address indexed recipient, bytes32 hash);

  function sendMessage(address to, string contents) {
    // Get message hash.
    bytes32 hash = sha3(contents);
    // Do we already have this message?
    for (uint i = 0; i < hashes[to].length; i++) {
      if (hashes[to][i] == hash) {
        return;
      }
    }
    // Is there a free slot?
    for (i = 0; i < hashes[to].length; i++) {
      if (hashes[to][i] == 0) {
        break;
      }
    }
    if (i == hashes[to].length) {
      // No free slot - make the array bigger.
      hashes[to].length++;
    }
    // Store the message.
    hashes[to][i] = hash;
    messages[to][hash] = Message(uint64(now), contents);
    // Trigger event.
    NewMessage(to, hash);
  }

  function getMessageHashes() constant returns (bytes32[]) {
    return hashes[msg.sender];
  }

  function getMessageTime(bytes32 hash) constant returns (uint) {
    return messages[msg.sender][hash].time;
  }

  function getMessageContents(bytes32 hash) constant returns (string) {
    return messages[msg.sender][hash].contents;
  }

  function deleteMessage(bytes32 hash) {
    delete messages[msg.sender][hash];
    for (uint i = 0; i < hashes[msg.sender].length; i++) {
      if (hashes[msg.sender][i] == hash) {
        delete hashes[msg.sender][i];
      }
    }
  }

}
