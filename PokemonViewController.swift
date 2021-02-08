import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    var caughtPokemon: [String]!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var pokemonImage: UIImageView!

    var pokemon: [PokemonListResult] = []
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        caughtPokemon = UserDefaults.standard.array(forKey: "CaughtPokemon") as? [String] ?? []
        loadPokemon()
        
        
    }


    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)

                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    
                    guard let imageURL = URL(string: result.sprites.front_default) else {
                        return
                        
                    }
                    if let data = try? Data(contentsOf: imageURL) {
                        self.pokemonImage.image = UIImage(data: data)
                    }
                    
                    self.setCatchLabelButton()
                }
            }
            catch let error {
                print(error)
            }

        }.resume()
        

    }

    
    
    @IBAction func toggleCatch() {
        if caughtPokemon.contains(nameLabel.text!) {
            caughtPokemon = caughtPokemon.filter { $0 != nameLabel.text! }
            UserDefaults.standard.set(caughtPokemon, forKey: "CaughtPokemon")
        } else {
            caughtPokemon.append(nameLabel.text!)
            UserDefaults.standard.set(caughtPokemon, forKey: "CaughtPokemon")
        }
        
        setCatchLabelButton()
    }
    
    func setCatchLabelButton() {
        let buttonLabel = caughtPokemon.contains(nameLabel.text!) ? "Release" : "Caught"
        catchButton.setTitle(buttonLabel, for: [.normal])
    }
    
}
