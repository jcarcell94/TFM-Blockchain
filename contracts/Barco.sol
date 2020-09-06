pragma solidity ^0.5.11; 

import './Libraries/Ownable.sol';
import './Libraries/SafeMath.sol'; 

contract Barco is Ownable{
    
    using SafeMath for uint;
    
    address public barcoDir; // Direccion del contrato
    Embarcacion barco; 
    // Estructura de datos embarcación
    
    struct Embarcacion{
        string IMO; //ID único de la embarcación ( IMO + 7 digitos) Ej: IMO 8814275
        string modelo; //modelo del barco
        string tipoEmbarcacion; //propósito de la embarcación
        uint eslora; 
        uint manga;
        string motor; //tipo de motor
        uint fechaBotadura; //fecha en formato UNIX timestamp
        uint numLicencia; //licencia de explotación del barco
        string puerto; //puerto en el que está registrado el barco
        uint capacidadCarga;
    }
    
    // Estructura de datos para el tripulante de la embarcación
    
    struct Tripulante{
        string DNI;
        string nombre;
        string apellidos;
        string puesto;
        uint certificado;
    }
    
   Tripulante[] public Tripulacion; 
   mapping (string => bool) Tripulantes; // Mapping de DNI -> Activo
   
   // Eventos
   event shipCreated(address indexed owner, address indexed barcoDir);
    
   //Creación del Barco
    constructor (string memory _IMO, string memory _modelo, string memory _tipoEmbarcacion, uint _eslora, uint _manga, 
    string memory _motor, uint _fechaBotadura, uint _numLicencia, string memory _puerto, uint _capacidadCarga) public{

        barcoDir = address(this);
        barco = Embarcacion(_IMO, _modelo, _tipoEmbarcacion, _eslora, _manga,
        _motor, _fechaBotadura, _numLicencia, _puerto, _capacidadCarga);
        emit shipCreated(owner(), barcoDir);
    }
    

    //Información completa del Barco
    function getBarco() public view returns (string memory _IMO, string memory _modelo, string memory _tipoEmbarcacion,  
                                            uint _numLicencia, string memory _puerto) {
        Embarcacion memory b = barco;
        return (b.IMO, b.modelo, b.tipoEmbarcacion, b.numLicencia, b.puerto);
    }

    function setPuerto(string memory _puerto) onlyOwner public{
        barco.puerto = _puerto;
    }
    

    function anyadirTripulante(string memory _DNI, string memory _nombre, string memory _apellidos, string memory _puesto,  uint _certificado) onlyOwner public {
        // La peticion debe ser enviada por el creador y el tripulante no estar en la lista
        require(!Tripulantes[_DNI]);
        Tripulante memory tripulante;
        tripulante.DNI = _DNI;
        tripulante.nombre = _nombre;
        tripulante.apellidos = _apellidos;
        tripulante.puesto = _puesto;
        tripulante.certificado = _certificado;
        Tripulacion.push(tripulante);
        Tripulantes[_DNI] = true;
    }
    
    function quitarTripulante(string memory _DNI) onlyOwner public {
        // La peticion debe ser enviada por el creador y el tripulante estar en la lista
        require(Tripulantes[_DNI]);
        for (uint i=0;i<Tripulacion.length;i++){
            if(compareStrings(Tripulacion[i].DNI, _DNI)){
                Tripulacion[i] = Tripulacion[Tripulacion.length-1];
                delete Tripulacion[Tripulacion.length-1];
                Tripulacion.length--;
                Tripulantes[_DNI] = false;
                break;
            }
        }
    }

    function compareStrings (string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
       }

}
