import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    var pokemon: [PokemonListResult] = []
    var pokemonSearch: [PokemonListResult] = []
    
    @IBOutlet var searchBar: UISearchBar!
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                self.pokemonSearch = self.pokemon
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonSearch.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        cell.textLabel?.text = capitalize(text: pokemonSearch[indexPath.row].name)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
           let destination = segue.destination as? PokemonViewController,
           let index = tableView.indexPathForSelectedRow?.row {
            destination.url = pokemonSearch[index].url
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty{
            pokemonSearch = pokemon
        }
        else {
            pokemonSearch = []
            for entryPokemon in self.pokemon {
                if entryPokemon.name.contains(searchText.lowercased()){
                    pokemonSearch.append(entryPokemon)
                }
            }
        }
        tableView.reloadData()
    }
}
