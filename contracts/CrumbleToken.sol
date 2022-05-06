//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// NFT
contract CrumbleToken is ERC721URIStorage{
    // NFT에서 필요한 것들?
    // TODO: mint
    // 민팅 = 블록체인에 아이템을 기록함
    // 1. 토큰 생성
    // 2. 생성한 토큰 리스팅 = market에 올림(판매 가능한 상태로 변경)
    // 3. 민팅(판매) 진행
    // 3-1. 소유자 전환
    // 3-2. 구매자로부터 판매자에게 리스팅한 금액만큼이 넘어감
    // 3-3. 판매리스트에서 내려감
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    // address public marketplace;
    address payable owner;
    uint256 private _mintIdx;

    constructor () ERC721("Crumble","CRB") {
        owner = payable(msg.sender);
        _mintIdx = 1;
    }

    // NFT에 대한 정보 작성
    struct Crumble {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool isSold;
    }

    event CrumbleCreated (
        uint256 tokenId,
        address seller,
        address owner,
        uint256 price,
        bool isSold
    );

    mapping(uint256 => Crumble) public crumbles;

    function createCrumble(string memory tokenURI, uint256 price) public returns (uint256) {
        _tokenId.increment();
        uint256 newTokenId = _tokenId.current();

        // token 생성
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        // 발행한 NFT를 판매할 수 있도록 변경 >> owner를 contract로 변경
        approve(address(this), newTokenId);

        crumbles[newTokenId] = Crumble({
            tokenId: newTokenId,
            seller: payable(msg.sender),
            owner: payable(address(this)),
            price: price,
            isSold: false
        });

        emit CrumbleCreated(newTokenId, msg.sender, address(this), price, false);

        return newTokenId;
    }

    // transfer를 하기 위해서는 함수가 payable이어야함 >> 돈의 이동이 있을 때에는 payable이 필수
    function publicMint() public payable {
        // 민팅을 하는 사람에게 랜덤 or 순차적으로 생성되어있는 NFT를 넘겨줌
        // 한 번에 하나의 NFT가 민팅됨
        uint price = crumbles[_mintIdx].price;

        require(owner == msg.sender, "Owner can't mint Crumble");
        require(_tokenId.current() < _mintIdx, "All Crumble are sold");
        require(msg.value == price, "Not enough ETH");

        crumbles[_mintIdx].seller = payable(address(0)); // seller가 없음
        crumbles[_mintIdx].owner = payable(msg.sender); // owner가 변경됨
        crumbles[_mintIdx].isSold = true;
        _mint(msg.sender, _mintIdx);
        _mintIdx += 1;

        // 민팅을 성공하면 출금이 일어남        
        crumbles[_mintIdx].owner.transfer(price);
        crumbles[_mintIdx].seller.transfer(msg.value);
    }

    // function setMarketplace(address market) public {
    //     marketplace = market;
    // }


    // function tokenId() public view returns (uint256) {
    //     return _tokenId.current();
    // }

    // function getItem(uint256 tokenId) public view returns (ItemToken memory) {
    //     return Items[tokenId];
    // }

    // function setItem(uint256 tokenId, address seller, address owner, address creator, string memory uri, bool sold) external pure returns (ItemToken memory){
    //     return ItemToken(tokenId, payable(seller), payable(owner), creator, uri, sold);
    // }
    
}