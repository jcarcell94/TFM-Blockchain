pragma solidity ^0.5.11;

import '../Libraries/Ownable.sol';

contract FactoriaStorage is Ownable{
    
    address[] public viajes;
    address[] public barcos;
    address factoryAddress;
    mapping(address => address) viajeOwner;
    mapping(address => address) barcoOwner;
    mapping(string => address) IMOBarco;
    uint id; /// Numerico autoincremental
    
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
    
    function addViaje(address _viaje, address _owner) onlyFactory external {
        viajes.push(_viaje);
        viajeOwner[_viaje] = _owner;
    }
    
    function getViajes() onlyFactory public view returns(address[] memory){
        return viajes;
    }
    
    function addBarco(address _barco, address _owner,string calldata _IMO) onlyFactory external {
        barcos.push(_barco);
        barcoOwner[_barco] = _owner;
        IMOBarco[_IMO] = _barco;
    }
    
    function getBarcos() onlyFactory public view returns(address[] memory){
        return barcos;
    }
    
    /// Cuando se quiere desplegar una nueva version de factoria 
    /// la version actual de facotry indica cual es la nueva version de factory
    function changeFactoryVersion(address newFactory) external onlyFactory {
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
    
    /// Devulve un nuevo id para viaje
    function newId() external returns(uint256) {
        id += 1;
        return id;
    }
    
    function validIMO(string calldata _IMO) external view returns(bool) {
        if(IMOBarco[_IMO] == address(0)) return false;
        else return true;
    }
}
