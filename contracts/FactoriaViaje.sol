pragma solidity ^0.5.11;

import './Barco.sol';
import './Viaje.sol';
import './FactoriaStorage.sol';

contract FactoriaViaje {
   
   FactoriaStorage public factoriaStorage;
   
   constructor() public{
      factoriaStorage = new FactoriaStorage();
   }
    
    // Crear un nuevo viaje y añadir la dirección
    function createTravel( uint _ID, string memory _empresa, string memory _puertoIni, string memory _puertoFinalEst, string memory _proposito, address _barcoDir) public{
        Viaje newViaje = new Viaje(_ID, _empresa, _puertoIni, _puertoFinalEst, _proposito, _barcoDir);
        factoriaStorage.addViaje(address(newViaje));
    }

    // Crear un barco y añadir la dirección
    function createBoat(string memory _IMO, string memory _modelo, string memory _tipoEmbarcacion, uint _eslora, uint _manga, uint _puntal, 
    string memory _motor, uint _fechaBotadura, uint _numLicencia, string memory _puerto, uint _capacidadCarga, string memory _bandera) public{

        Barco newBarco = new Barco(string memory _IMO, string memory _modelo, string memory _tipoEmbarcacion, uint _eslora, uint _manga, uint _puntal, 
    string memory _motor, uint _fechaBotadura, uint _numLicencia, string memory _puerto, uint _capacidadCarga, string memory _bandera);
        factoriaStorage.addBarco(address(newBarco));
    }
    


    // Devuelve una lista de las direcciones de los viajes
    function getViajes() public view returns (address[] memory){
        return factoriaStorage.getViajes();
    }
    
    // Devuelve la información del viaje
    function getViaje(address viajeAddress) public view returns (uint _ID, string memory _puertoIni, string memory _proposito, EstadoViaje _estadoViaje, EstadoBarco estadoBarco){
        Viaje viaje = Viaje(viajeAddress);
        return viaje.getViaje();
    }
    
    // Devuelve el estado de un viaje
    function getStatus(address viajeAddress) public view returns(EstadoBarco _estadoBarco){
        Viaje viaje = Viaje(viajeAddress);
        return viaje.getStatus();
    }

    // Devuelve la última localización del barco
    function getLocalization(address viajeAddress) public view returns(bytes32 _localizacion){
        Viaje viaje = Viaje(viajeAddress);
        return viaje.getLocalization();
    }
    
}
    




