pragma solidity ^0.5.11;

import './Barco.sol';
import './Viaje.sol';
import './FactoriaStorage.sol';

contract FactoriaViaje {
   
   FactoriaStorage public factoriaStorage;
   bool paused;
   
   constructor() public{
      factoriaStorage = new FactoriaStorage();
   }
   
   modifier notPaused() {
       require(!paused,'Contract is paused');
       _;
   }

    // Crear un nuevo viaje y añadir la dirección
    function createTravel( uint _ID, string memory _empresa, string memory _puertoIni, string memory _puertoFinalEst, string memory _proposito, address _barcoDir) notPaused public{
        Viaje newViaje = new Viaje(_ID, _empresa, _puertoIni, _puertoFinalEst, _proposito, _barcoDir);
        factoriaStorage.addViaje(address(newViaje));
    }

    // Devuelve una lista de las direcciones de los viajes
    function getViajes() public view returns (address[] memory){
        return factoriaStorage.getViajes();
    }
 
    // Devuelve la información del viaje
    function getViaje(address viajeAddress) public view returns (uint _ID, string memory _puertoIni, string memory _proposito, string memory _estadoViaje, string memory _estadoBarco){
        Viaje viaje = Viaje(viajeAddress);
        return viaje.getViaje();
    }
    
    // Devuelve el estado de un viaje
    function getStatusBarco(address viajeAddress) public view returns(string memory _estadoBarco){
        Viaje viaje = Viaje(viajeAddress);
        return viaje.getStatusBarco();
    }

    function getStatusViaje(address viajeAddress) public view returns(string memory _estadoViaje){
        Viaje viaje = Viaje(viajeAddress);
        return viaje.getStatusViaje();
        }
        
    // Devuelve la última localización del barco
    function getLocalization(address viajeAddress) public view returns(bytes32 _localizacion){
        Viaje viaje = Viaje(viajeAddress);
        return viaje.getLocalization();
    }
    
    function changeFactoryVersion(address newFactory) notPaused public {
        FactoriaStorage fs = FactoriaStorage(factoriaStorage);
        fs.changeFactoryVersion(newFactory);
    }
    
    function emergencyStop() public {
        paused = true;
    }
    
    function resume() public {
        paused = false;
    }

}
