pragma solidity ^0.5.11;

contract FactoriaStorage{
    
    address[] public viajes;
    address[] public barcos;
    address storageDir;
    
    constructor() public {
    }
    
    function addViaje(address _viaje) public {
        lotteries.push(_viaje);
    }
    
    function getViajes() public view returns(address[] memory){
        return viajes;
    }
    
    function addBarco(address _barco) public {
        lotteries.push(_barco);
    }
    
    function getViajes() public view returns(address[] memory){
        return barcos;
    }

    function getDir() public view returns(address _dir){
        return address(this);
    }
}

