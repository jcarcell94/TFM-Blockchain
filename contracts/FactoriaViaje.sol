pragma solidity ^0.5.11;

import './Barco.sol';
import './Viaje.sol';
import './FactoriaStorage.sol';
import '../Libraries/Ownable.sol';

contract FactoriaViaje is Ownable{
   
   FactoriaStorage public factoriaStorage;
   bool paused;
   
   event NewBarco(address indexed _owner, address _barco);
   event NewViaje(address indexed _owner, address _barco, address _vaije);
   event EmergencyStop(bool _stop);
   
   constructor() public{
      factoriaStorage = new FactoriaStorage();
   }
   
   modifier notPaused() {
       require(!paused,'Contract is paused');
       _;
   }
   
   // Crear un nuevo Barco
   function createBarco(string memory _IMO, string memory _tipoEmbarcacion, uint _eslora, uint _manga, 
    string memory _motor, uint _fechaBotadura, uint _numLicencia, string memory _puerto, uint _capacidadCarga) public{
        require(factoriaStorage.validIMO(_IMO), 'IMO en uso.');
        Barco newBarco = new Barco(_IMO, _tipoEmbarcacion, _eslora, _manga, _motor, _fechaBotadura, 
                                    _numLicencia, _puerto, _capacidadCarga);
        newBarco.transferOwnership(msg.sender);
        factoriaStorage.addBarco(address(newBarco), msg.sender, _IMO);
        emit NewBarco(msg.sender, address(newBarco));
   }

    // Crear un nuevo viaje y añadir la dirección
    function createTravel(string memory _empresa, string memory _puertoIni, string memory _puertoFinalEst, string memory _proposito, address _barcoDir) notPaused onlyOwner public{
        require(Barco(_barcoDir).owner() == msg.sender,'No tiene permisos para crear el viaje o direccion de barco invalida');
        Viaje newViaje = new Viaje(factoriaStorage.newId(), _empresa, _puertoIni, _puertoFinalEst, _proposito, _barcoDir);
        newViaje.transferOwnership(msg.sender);
        factoriaStorage.addViaje(address(newViaje), msg.sender);
        emit NewViaje(msg.sender, _barcoDir, address(newViaje));
    }

    // Devuelve una lista de las direcciones de los barcos
    function getBarcos() public view returns (address[] memory){
        return factoriaStorage.getBarcos();
    }
    
    // Devuelve una lista de las direcciones de los viajes
    function getViajes() public view returns (address[] memory){
        return factoriaStorage.getViajes();
    }
    
    function changeFactoryVersion(address newFactory) notPaused onlyOwner public {
        FactoriaStorage fs = FactoriaStorage(factoriaStorage);
        fs.changeFactoryVersion(newFactory);
    }
    
    function emergencyStop() onlyOwner public{
        paused = true;
        emit EmergencyStop(true);
    }
    
    function resume() onlyOwner public{
        paused = false;
        emit EmergencyStop(false);
    }

}
