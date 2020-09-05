pragma solidity ^0.5.11;

import './Libraries/Ownable.sol';

contract FactoriaStorage is Ownable{
    
    address[] public viajes;
    /// address[] public barcos;
    address storageDir;
    address factoryAddress;
    
    /// Evento para notificar un cambio de version en la factoria
    /// Indica cual era la direccion de la version anterior de la facotira y la nueva por la que se ha cambiado
    event FactoryVersionChanged(address indexed previousOwner, address indexed newOwner);
    
    constructor() public {
        factoryAddress = msg.sender;
    }
    
    //// Modificador de acceso. Solo la version actual de factory tiene acceso
    modifier onlyFactory() {
        require(msg.sender == factoryAddress, 'Only last factory version');
        _;
    }
    
    function addViaje(address _viaje) onlyFactory public {
        viajes.push(_viaje);
    }
    
    function getViajes() onlyFactory public view returns(address[] memory){
        return viajes;
    }
    
    /**function addBarco(address _barco) public {
        barcos.push(_barco);
    }
    
    function getBarcos() public view returns(address[] memory){
        return barcos;
    }**/

    function getDir() public view returns(address _dir){
        return address(this);
    }
    
    /// Cuando se quiere desplegar una nueva version de factoria 
    /// la version actual de facotry indica cual es la nueva version de factory
    function changeFactoryVersion(address newFactory) public onlyFactory {
        _changeFactoryVersion(newFactory); 
    }
    
    function _changeFactoryVersion(address newFactory) internal {
        require(factoryAddress != address(0), "Ownable: new owner is the zero address"); 
        emit FactoryVersionChanged(factoryAddress, newFactory);
        factoryAddress = newFactory;
    }
    
    // Fallback function
    function() external payable{
        require(msg.value == 0, 'Este contrato no acepta Ether');
    }
}
