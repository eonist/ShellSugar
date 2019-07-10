import Foundation

extension ShellHelper {/*BETA*/
   /**
    * BETA
    * NOTE: ⚠️️ supports piping ⚠️️
    * CAUTION: ⚠️️ use this method for hard coded commands, not for commands that the user can insert data ⚠️️
    */
   static func unsafeRun(_ input: String, _ cd: String = "") -> String {
      let (output, terminationStatus) = ShellHelper.unsafeExc(input, cd)
      //Swift.print("terminationStatus: " + "\(terminationStatus)")
      _ = terminationStatus
      return output
   }
   /**
    * BETA
    * NOTE: supports piping
    */
   static func unsafeExc(_ input: String, _ cd: String = "") -> (output: String, exitCode: Int32) {
      let task = Process()
      task.currentDirectoryPath = cd
      task.launchPath = "/bin/sh"/*Setting shell as launchPath enables piping support*/ //--> /bin/bash should also work
      task.arguments = ["-c", input]/*I think the -c part enables auto path resolvment and support for piping etc*/
      let pipe = Pipe()
      task.standardOutput = pipe
      task.launch()
      //Fixme: ⚠️️ moving waitUntilExit bellow output retrieval could enable bigger outputs. Aka big outputs may never complete if its not bellow. ⚠️️
      task.waitUntilExit()/*Makes sure it finishes before proceeding. If the task can be asynchronous, you can remove that call and just let the NSTask do it's thing.*/
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
      return (output, task.terminationStatus)
   }
}
