import UIKit

// MARK: - Helper objects
/// A method called when a row is tapped from a table view
typealias TapRowAction = (() -> Void)

/// A section in a table view table view
typealias SectionData = (header: String?,
                         footer: String?,
                         rows: [RowItem])

/// A row in a table view
struct RowItem {
  /// Text on left of cell
  var title: String? = nil
  
  /// Text on right of cell
  var previewText: String? = nil
  
  /// 
  var imageUrl: String? = nil
  
  /// Cell accessory to show
  var accessory: UITableViewCell.AccessoryType = .none
  
  /// Function to call when the cell is selected
  var action: TapRowAction? = nil
}

// MARK: - DetailViewController
/// Shows info about a character
class DetailViewController: UITableViewController {
  var data: [SectionData] = []
  var character: Character
  
  init(character: Character) {
    self.character = character
    super.init(style: .insetGrouped)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Page life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = character.name
    
    data = makeData()
    tableView.register(UINib(nibName: "BigImageTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "BigImageTableViewCell")
    tableView.reloadData()
  }
  
  // MARK: - Methods
  /// Create data for display in table view.
  func makeData() -> [SectionData] {
    let nilString: String? = nil
    
    var tableData = [
      (
        header: nilString,
        footer: nilString,
        rows: [
          RowItem(imageUrl: character.thumbnailUrl)
        ]
      )]
    
    if character.marvelDescription != nil {
      tableData.append(
        (
          header: nilString,
          footer: nilString,
          rows: [
            RowItem(title: character.marvelDescription, previewText: nil, accessory: .none, action: { 
              
            })
          ]
        )
      )
    }
    
    if (character.series?.count ?? 0) > 0 {
      let allSeries = character.series!.allObjects as! [Series]
      var rows: [RowItem] = []
      for series in allSeries {
        rows.append(
          RowItem(title: series.name, previewText: nil, accessory: .none, action: { 
          
          })
        )
      }
      
      tableData.append(
        (
          header: "Top Series",
          footer: nilString,
          rows: rows
        )
      )
    }
    
    if let readMoreLink = character.readMoreLink {
      tableData.append(
        (
          header: nilString,
          footer: nilString,
          rows: [
            RowItem(title: "View on marvel.com", previewText: nil, accessory: .disclosureIndicator, action: {
              if let url = URL(string: readMoreLink) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
              }
            })
          ]
        )
      )
    }
    
    return tableData
  }
  
  // MARK: - UITableViewDelegate
  override func numberOfSections(in tableView: UITableView) -> Int {
    return data.count
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data[section].rows.count
  }
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return data[section].header
  }
  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return data[section].footer
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = data[indexPath.section].rows[indexPath.row]
    
    if indexPath.section == 0 {
      // top most image view
      let cell = tableView.dequeueReusableCell(withIdentifier: "BigImageTableViewCell") as! BigImageTableViewCell
      cell.configureCell(character: character)
      return cell
    } else {
      // regular cells
      let cell = UITableViewCell(style: .value1, reuseIdentifier: "ReuseDetailCell")
      cell.textLabel?.text = item.title
      cell.textLabel?.numberOfLines = 0
      
      cell.detailTextLabel?.text = item.previewText
      cell.accessoryType = item.accessory
      return cell
    }
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = data[indexPath.section].rows[indexPath.row]
    
    item.action?()
  }
  
}



