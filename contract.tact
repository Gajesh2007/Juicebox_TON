import "@stdlib/deploy";
import "@stdlib/jetton";

contract Juicebox with Deployable, Jetton {
    totalSupply: Int as coins;
    owner: Address;
    content: Cell?;
    mintable: Bool;

    // State
    // 0 - CLOSED
    // 1 - OPEN
    state: Int;
 
    init(owner: Address, content: Cell?) {
        self.totalSupply = 0;
        self.owner = owner;
        self.mintable = true;
        self.content = content;
        self.state = 1;
    }
 
    receive("contribute") {
        let ctx: Context = context();
        let value: Int = ctx.value;

        require(self.state == 1, "not open");

        self.mint(ctx.sender, value, ctx.sender);
    }

    receive("withdraw") {
        require(self.state == 0, "not closed");
        require(self.owner == context().sender, "not owner");

        let balance: Int = myBalance();

        send(SendParameters{
            to: context().sender,
            value: balance, 
            mode: SendIgnoreErrors, 
            bounce: true, 
            body: "Withdrawn!".asComment()
        });
    }

    receive("close") {
        require(self.state == 1, "not open");
        require(self.owner == context().sender, "not owner");

        self.state = 0;
    }

    get fun totalSupply(): Int {
        return self.totalSupply;
    }
}